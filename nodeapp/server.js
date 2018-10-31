var server = require('http').createServer();
var io = require('socket.io')(server);
io.on('connection', function(client){
    client.on('event', function(data){});
    client.on('disconnect', function(){});  
});
server.listen(8080);

var io = require('socket.io')();
io.on('connection',function(client){});
//io.listen(8080);

var app = require('express')();
var server = require('http').createServer(app);
var io = require('socket.io')(server);
io.on('connection', function(){
})



io.on('connection', function(socket){
    socket.emit('request', console.log("emit an event to the socket"));
    io.emit('broadcast', console.log("emit an event to all connected sockets"));
    socket.on('reply', function(){
        console.log("listen to the event");
    })
})