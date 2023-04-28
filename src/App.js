
import React from 'react';
import './App.css';
import { useState } from 'react';
import Axios from "axios";
function App() {
  const [name,setName]=useState("");
  const addUser=async (event)=>{
    event.preventDefault();
    Axios.post('http://192.46.238.198:3002/adduser',{
      name:name
    })    
  }
  return (
    <div className="App">
      <label>insert user  new</label>
      <input onChange={(e)=>setName(e.target.value)} name="name"/>
     <button onClick={addUser}>submit</button>
    </div>
  );
}

export default App;
