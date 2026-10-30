import React, { useState } from "react";
import axios from "axios";

interface NewPasswordFormProps {
  onPasswordResetSuccess: () => void;
}

function NewPasswordForm({ onPasswordResetSuccess }: NewPasswordFormProps) {
  const [code, setCode] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSetCode(e: React.ChangeEvent<HTMLInputElement>): void {
    setCode(e.target.value);
  }

  function handleSetNewPassword(e: React.ChangeEvent<HTMLInputElement>): void {
    setNewPassword(e.target.value);
  }

  async function doResetPassword(
    event: React.SubmitEvent<HTMLFormElement>,
  ): Promise<void> {
    event.preventDefault();

    if (isSubmitting) {
      return;
    }

    const obj = {
      code: code,
      new_password: newPassword,
    };

    try {
      setIsSubmitting(true);
      setMessage("Resetting password...");

      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/login/reset",
        obj,
      );

      const res = response.data;

      if (res.status === "success") {
        onPasswordResetSuccess();
      } else {
        setMessage(res.reason || "Unable to reset password.");
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
      onSubmit={doResetPassword}
    >
      <h2 className="fw-bold mb-4">New Password</h2>

      <p className="text-center">
        Enter the recovery code sent to your email and choose a new password.
      </p>

      <input
        type="text"
        placeholder="Recovery Code"
        className="form-control w-75 mb-4"
        value={code}
        onChange={handleSetCode}
        required
      />

      <input
        type="password"
        placeholder="New Password"
        className="form-control w-75 mb-4"
        value={newPassword}
        onChange={handleSetNewPassword}
        minLength={8}
        required
      />

      <button
        type="submit"
        className="btn bg-white text-black px-5"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Resetting..." : "Reset Password"}
      </button>

      <span className="mt-3">{message}</span>
    </form>
  );
}

export default NewPasswordForm;
