import React, { Component } from 'react';
import './App.css';

class App extends Component {
  constructor(){
    super();
    this.get = this.get.bind(this);
    this.post = this.post.bind(this);
    this.fetch = this.fetch.bind(this);
  }
  get() {
    fetch('/api/get', { // 在URL中写上传递的参数
      method: 'GET'
    })
      .then((res) => {
        console.log(res)
        return res.text()
      })
      .then((res) => {
        console.log(res)
      })
  }
  post(){
    const url = '/api/post'
    const opts = {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          name: 'Hubot',
          login: 'hubot',
        })
    }
    fetch(url, opts)
      .then((res) => {
        //网络请求成功,执行该回调函数,得到响应对象,通过response可以获取请求的数据
        //json text等

        //你可以在这个时候将Promise对象转换成json对象:response.json()
        //转换成json对象后return，给下一步的.then处理

        return res.json();
        //或 return response.json();
      })
      .then((res) => {
        console.log(res)
        //处理请求得到的数据
      })
      .catch((error) => {
        //网络请求失败,执行该回到函数,得到错误信息
      })
  }
  fetch(){
    const url = '/api/post'
    const opts = {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          name: 'Hubot',
          login: 'hubot',
        })
    }
    fetch(url, opts)
      .then((res) => {
        //网络请求成功,执行该回调函数,得到响应对象,通过response可以获取请求的数据
        //json text等
        //你可以在这个时候将Promise对象转换成json对象:response.json()
        //转换成json对象后return，给下一步的.then处理
        return res.json();
        //或 return response.json();
      })
      .then((res) => {
        console.log(res)
        //处理请求得到的数据
        fetch('/api/get', { // 在URL中写上传递的参数
          method: 'GET'
        })
          .then((response) => {
            console.log(response)
            return response.text()
          })
          .then((response) => {
            console.log(response)
          })
      })
      .catch((error) => {
        //网络请求失败,执行该回到函数,得到错误信息
      })
  }
  render() {
    return (
      <div className="App">
        <button onClick={this.get}>get</button>
        <button onClick={this.post}>post</button>
        <button onClick={this.fetch}>fetch</button>
      </div>
    );
  }
}

export default App;

// https://segmentfault.com/a/1190000007019545