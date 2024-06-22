const express=require('express');
var mysql=require('mysql');

var connection=mysql.createConnection
({
    host : 'localhost',
    user : 'root',//root2
    password : '',
    port : '3306',        // 3306 is default port no. of mysql 
    database : 'pfa'  // your db name
});


connection.connect(function(err){
    if(err) throw err;
    console.log('db connected');
});


module.exports = connection;