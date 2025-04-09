import { AllRoutes } from "./Components/Routes/AllRoutes";
import { useSelector } from "react-redux";

function App() {
  // Example of using Redux state
 // const someState = useSelector(state => state.someValue);  //error correction

  return (
    <>
      <AllRoutes />
    </>
  );
}

export default App;