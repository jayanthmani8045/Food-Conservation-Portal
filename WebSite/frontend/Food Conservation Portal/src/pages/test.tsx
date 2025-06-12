import axios from "axios";
import { useEffect, useState } from "react";

function Test(){
  const [con, setCon] = useState("Loading");
  useEffect(() => {
    axios.get('http://127.0.0.1:8000/')
    .then(response => {
    console.log('Response:', response.data);
    setCon(() => response.data);
  })
  .catch(error => {
    console.error('Error:', error);
    setCon(() => error);
  });
  }, []);
  
  return (
    <div>
      <h1>Test Frontend : {con}</h1>
    </div>
  );
}

export default Test;