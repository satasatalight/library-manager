import React, { useState } from "react";
import axios from "axios";

function LoginForm() {
  const [loginEmail, setLoginEmail] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSetLoginEmail(e: React.ChangeEvent<HTMLInputElement>): void {
    setLoginEmail(e.target.value);
  }

  function handleSetPassword(e: React.ChangeEvent<HTMLInputElement>): void {
    setLoginPassword(e.target.value);
  }

  async function doLogin(
    event: React.SubmitEvent<HTMLFormElement>,
  ): Promise<void> {
    event.preventDefault();

    if (isSubmitting) {
      return;
    }

    const obj = {
      email: loginEmail,
      password: loginPassword,
    };

    try {
      setIsSubmitting(true);
      setMessage("Logging in...");

      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/login",
        obj,
      );

      const res = response.data;

      if (res.status === "success" && typeof res.token === "string") {
        sessionStorage.setItem("token", res.token);
        setMessage("Login successful!");
      } else {
        setMessage(res.reason || "Login failed.");
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
      onSubmit={doLogin}
    >
      <input
        type="email"
        placeholder="Email"
        className="form-control w-75 mb-4"
        value={loginEmail}
        onChange={handleSetLoginEmail}
        required
      />

      <input
        type="password"
        placeholder="Password"
        className="form-control w-75 mb-4"
        value={loginPassword}
        onChange={handleSetPassword}
        required
      />

      <button
        type="submit"
        className="btn btn-accent px-5"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Logging in..." : "Login"}
      </button>

      <span className="mt-3">{message}</span>
    </form>
  );
}

export default LoginForm;
