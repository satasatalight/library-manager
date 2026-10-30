import React, { useState } from "react";
import axios from "axios";

interface ResetFormProps {
  onResetRequested: () => void;
}

function ResetForm({ onResetRequested }: ResetFormProps) {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSetEmail(e: React.ChangeEvent<HTMLInputElement>): void {
    setEmail(e.target.value);
  }

  async function doReset(
    event: React.SubmitEvent<HTMLFormElement>,
  ): Promise<void> {
    event.preventDefault();

    if (isSubmitting) {
      return;
    }

    const obj = {
      email: email,
    };

    try {
      setIsSubmitting(true);
      setMessage("Sending recovery email...");

      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/login/request_reset",
        obj,
      );

      const res = response.data;

      if (res.status === "success") {
        onResetRequested();
      } else {
        setMessage(res.reason || "Unable to request password reset.");
      }
    } catch (error) {
      if (axios.isAxiosError(error)) {
        setMessage(
          error.response?.data?.reason || "Unable to connect to the server.",
        );
      } else {
        setMessage("Unable to connect to the server.");
      }

      console.error(error);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form
      className="d-flex flex-column align-items-center mt-5"
      onSubmit={doReset}
    >
      <h2 className="fw-bold mb-4">Recover Password</h2>

      <input
        type="email"
        placeholder="Email"
        className="form-control w-75 mb-4"
        value={email}
        onChange={handleSetEmail}
        required
      />

      <button
        type="submit"
        className="btn btn-accent px-5"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Sending..." : "Send Recovery Email"}
      </button>

      <span className="mt-3">{message}</span>
    </form>
  );
}

export default ResetForm;
