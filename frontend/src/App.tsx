import "./sass/styles.scss";
import ExampleCard from "./components/ExampleCard";

function App() {
  return (
    <div className="vh-100 w-100 bg-base">
      <div className="main container border-start border-end shadow-lg mx-auto px-5 pt-5 h-100 w-75 ">
        <h1 className="fs-head font-kurale">LitLog</h1>
        <div className="mt-4">
          <ExampleCard />

          {/* More components go down here */}
        </div>
      </div>
    </div>
  );
}

export default App;
