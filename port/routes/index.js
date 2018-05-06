var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.post('/post',function(req, res, next) {
  const body = req.body;
  res.send(body);
})

router.get('/get',function(res, req, next) {
  res.end('123')
})

module.exports = router;
