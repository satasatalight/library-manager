export default function ExampleCard() {
  return (
    <div className="border border-3 border-accent border-opacity-50 shadow-md rounded-4 w-50 py-3 px-3 bg-white">
      This is an example component that does a PUT request on the backend{" "}
      <code>/example</code> endpoint.
      <div className="mt-3 mb-2">Message to send to server:</div>
      <div className="input-group">
        <input
          type="text"
          className="form-control"
          placeholder="Message"
          id="message"
        ></input>
        <button className="btn btn-accent" type="button">
          Send
        </button>
      </div>
      <div className="mt-3 mb-2">Response from server:</div>
      <textarea className="form-control" readOnly></textarea>
    </div>
  );
}
