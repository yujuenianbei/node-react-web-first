var express = require('express');
var router = express.Router();

// respond with "hello world" when a GET request is made to the homepage
router.get('/get', function(req, res) {
  res.send('hello world');
});
  
router.post("/post", function(req, res) {
    const body = req.body
    console.log(body)
    res.send(body);
  });
  
  router.put("/put", function(req, res) {
    res.send("i don't see a lot of PUT requests anymore");
  });
  
  router.delete("/delet", function(req, res) {
    res.send("oh my, a DELETE??");
  });

module.exports = router;
