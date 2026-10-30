import React, { useState } from "react";
import axios from "axios";

interface VerifyFormProps {
  email: string;
  onVerifySuccess: () => void;
}

function VerifyForm({ email, onVerifySuccess }: VerifyFormProps) {
  const [code, setCode] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSetCode(e: React.ChangeEvent<HTMLInputElement>): void {
    setCode(e.target.value);
  }

  async function doVerify(
    event: React.SubmitEvent<HTMLFormElement>,
  ): Promise<void> {
    event.preventDefault();

    if (isSubmitting) {
      return;
    }

    const obj = {
      email: email,
      code: code,
    };

    try {
      setIsSubmitting(true);
      setMessage("Verifying email...");

      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/registration/verify",
        obj,
      );

      const res = response.data;

      if (res.status === "success") {
        onVerifySuccess();
      } else {
        setMessage(res.reason || "Unable to verify email.");
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
      onSubmit={doVerify}
    >
      <h2 className="fw-bold mb-4">Verify Email</h2>

      <p className="text-center">Enter the six-digit code sent to {email}.</p>

      <input
        type="text"
        placeholder="Verification Code"
        className="form-control w-75 mb-4"
        value={code}
        onChange={handleSetCode}
        maxLength={6}
        pattern="[0-9]{6}"
        inputMode="numeric"
        required
      />

      <button
        type="submit"
        className="btn bg-white text-black px-5"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Verifying..." : "Verify"}
      </button>

      <span className="mt-3">{message}</span>
    </form>
  );
}

export default VerifyForm;
