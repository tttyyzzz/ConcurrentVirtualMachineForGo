import React, { useState } from 'react';
import AceEditor from 'react-ace';
import 'ace-builds/src-noconflict/mode-javascript';
import 'ace-builds/src-noconflict/theme-monokai';
import 'ace-builds/src-noconflict/theme-twilight';
// import 'ace-builds/src-noconflict/theme-tomorrow_night_blue';

const CustomFrontend = () => {
  const [code, setCode] = useState('');
  const [one, setOne] = useState('');
  const [result, setResult] = useState('');


//   const handleRunClick = () => {
//     // Make a POST request to Express server
//     fetch('http://localhost:5000/', {
//         method: 'POST',
//         headers: {
//             'Content-Type': 'application/json'
//         },
//         body: JSON.stringify({ data: code }),
//         mode: 'cors'
//     })
//     .then(response => response.json())
//     .then(data => {
//         // Update the result variable with the response data
//         setResult(data);
//     })
//     .catch(error => {
//         console.error('Error:', error);
//         setResult(`Error: ${error.message}`);
//     });
// };

const resultSplit = () =>{
    console.log(result)
    if (result){
    const resultSplit = result.split("\n")
    return resultSplit.map((res,index) => <ul style={{ margin: '0', padding: '0' }} key={index}>{res}</ul>)
    }
    else {
        return result
    }
}
const handleRunClick = async () => {
    try {
        const response = await fetch('http://localhost:5000/', {
            method: 'POST',
            headers: {
                'Content-Type': 'text/plain' // Set the Content-Type header to text/plain
            },
            body: one // Use the code variable as the request body
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const data = await response.text(); // Assuming the response from the server is plain text
        console.log("This is one",one)
        console.log("This is the data",data)
        setResult(data)
        console.log('Response from Express:', data);
    } catch (error) {
        console.error('Error:', error);
    }
};

const settingCode = (value) => {
    setCode(value)
    setOne(value)

}
  return (
    // <div>
    //   <div style={{ float: 'left', width: '50%' }}>
    //     <AceEditor
    //       mode="javascript"
    //       theme="monokai"
    //       value={code}
    //       onChange={setCode}
    //       style={{ height: '300px', width: '100%' }}
    //     />
    //     <button onClick={handleRunClick}>Run</button>
    //   </div>
    //   <div style={{ float: 'right', width: '50%' }}>
    //     <h2>Result:</h2>
    //     <div>{result}</div>
    //   </div>
    // </div>
<div style={{ display: 'flex', flexDirection: 'row', height: '100vh' }}>
  <div style={{ flex: 1, backgroundColor: '#0C2035', padding: '20px', color: 'white' }}>
    <AceEditor
      mode="javascript"
      theme="twilight" // Use Source Academy-like dark blue theme
    //   value={code}
    value = {code}
      onChange={settingCode}
      style={{ height: 'calc(100% - 40px)', width: '100%' }} // Adjust height to account for button
    />
    <button onClick={handleRunClick} style={{ marginTop: '20px' }}>Run</button>
  </div>
  <div style={{ flex: 1, backgroundColor: '#212121', padding: '20px', color: 'white' }}>
    <h2>Result:</h2>
    {resultSplit()}
  </div>
</div>
  );
};

export default CustomFrontend;
