import { useEffect, useState } from "react";
import type { JSX } from "react";

function App(): JSX.Element {
  const [data, setData] = useState<string>("Loading...");
  
  useEffect(() => {
    async function load() {
      try {
        fetch("http://127.0.0.1:8000/")
        .then((res) => res.json())
        .then((data) => {
          setData(data);
        });
      } catch (e) {
        console.error(e);
        setData("Error fetching data");
      }
    }
    load();
  }, []);

  return <div>{data}</div>;
}

export default App;
