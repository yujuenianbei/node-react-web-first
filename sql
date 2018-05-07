import mysql from 'mysql/index';
import os from 'os';
import fs from 'fs';
import log4js from './log';
const log = log4js.getLogger('msyql');
import PipeRedisClient from './pipe-redis-client';
const ckm = new PipeRedisClient({
  command: `${process.env.IAM_CMS_DAEMON_HOME}/bin/iam-cms-daemon_${os.platform()}_${os.arch()}`,
  args: ['ionbf', 'clear_env_buf'],
});

ckm.command('ckm-config', ['keysdir', process.env.CIPHER_ROOT + '/'])
  .then(() => log.info('ckm ready.'));

let pool = null;

const initMysql = () => {
  try {
    // 初始化mysql数据库
    log.info('---init Mysql----');
    const packagenName = JSON.parse(fs.readFileSync('../etc/sysconf/deployment_env.json')).packageId;
    let dbConfig = JSON.parse(fs.readFileSync(`../etc/sysconf/${packagenName}.json`)).databases.mounionoperationdb[0];
    return ckm.command('ckm-decrypt', ['common_shared', new Buffer(dbConfig.passwd, 'hex')]).then((d) => {
      const poolConfig = {
        connectionLimit: 80,
        host: dbConfig.serverName,
        port: dbConfig.port,
        user: dbConfig.user,
        password: d.toString(),
        database: dbConfig.dbName,
        connectTimeout: 10000,
        multipleStatements: true,
      };
      pool = mysql.createPool(poolConfig);

      // 初始化数据库表
      const sql = fs.readFileSync('./init/init.sql').toString();
      pool.query(sql, (err, result) => {
        if (err) throw err;
        log.info(result);
      });
      pool.query('show tables;', (err, result) => {
        if (err) throw err;
        log.info(result);
      });
      if (dbConfig.passwd instanceof Buffer) {
        dbConfig.passwd.fill(0);
      }
      dbConfig = {};
      log.info('--init mysql end ---');
    }).catch(err => {
      log.error(`read db pw failed:${err}`);
      process.exit(254);
    });
  } catch (err) {
    log.error(err);
    return Promise.reject(err);
  }
};


const query = (sql, param, callback = () => {}, useTransaction) =>
  new Promise((resolve, reject) => {
    if (!pool) {
      callback('mysql pool not exist!', null, null);
      reject('mysql pool not exist!');
    } else {
      pool.getConnection((err, conn) => {
        if (err) {
          callback(err, null, null);
          reject(err);
        } else {
          if (useTransaction) {
            conn.beginTransaction(err => {
              if (err) {
                callback(err, null, null);
                reject(err);
              } else {
                conn.query(sql, param, (qerr, vals, fields) => {
                  // 释放连接
                  if (qerr) {
                    conn.rollback(() => log.error('excute sql error, rollback'));
                    conn.release();
                    callback(qerr, vals, fields);
                    reject(qerr);
                    return;
                  }
                  conn.commit(err => {
                    if (err) {
                      log.error('commit sql error');
                      log.error(err);
                      reject(err);
                    }
                  });
                  conn.release();
                  callback(qerr, vals, fields);
                  resolve(vals);
                  return;
                });
              }
            });
          } else {
            conn.query(sql, param, (qerr, vals, fields) => {
              conn.release();
              callback(qerr, vals, fields);
              if (qerr) {
                reject(qerr);
              } else {
                resolve(vals);
              }
            });
          }
        }
      });
    }
  });

module.exports = {
  query,
  initMysql
};
