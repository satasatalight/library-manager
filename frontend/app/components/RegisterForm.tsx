import React, { useState } from "react";
import axios from "axios";

interface RegisterFormProps {
  onRegisterSuccess: (email: string) => void;
}

function RegisterForm({ onRegisterSuccess }: RegisterFormProps) {
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSetFirstName(e: React.ChangeEvent<HTMLInputElement>): void {
    setFirstName(e.target.value);
  }

  function handleSetLastName(e: React.ChangeEvent<HTMLInputElement>): void {
    setLastName(e.target.value);
  }

  function handleSetEmail(e: React.ChangeEvent<HTMLInputElement>): void {
    setEmail(e.target.value);
  }

  function handleSetPassword(e: React.ChangeEvent<HTMLInputElement>): void {
    setPassword(e.target.value);
  }

  async function doRegister(
    event: React.SubmitEvent<HTMLFormElement>,
  ): Promise<void> {
    event.preventDefault();

    if (isSubmitting) {
      return;
    }

    const obj = {
      first_name: firstName,
      last_name: lastName,
      email: email,
      password: password,
    };

    try {
      setIsSubmitting(true);
      setMessage("Registering account...");

      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/register",
        obj,
      );

      const res = response.data;

      if (res.status === "success") {
        onRegisterSuccess(email);
      } else {
        setMessage(res.reason || "Registration failed.");
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
      onSubmit={doRegister}
    >
      <h2 className="fw-bold mb-5">Create Account</h2>

      <input
        type="text"
        placeholder="First Name"
        className="form-control w-75 mb-4"
        value={firstName}
        onChange={handleSetFirstName}
        required
      />

      <input
        type="text"
        placeholder="Last Name"
        className="form-control w-75 mb-4"
        value={lastName}
        onChange={handleSetLastName}
        required
      />

      <input
        type="email"
        placeholder="Email"
        className="form-control w-75 mb-4"
        value={email}
        onChange={handleSetEmail}
        required
      />

      <input
        type="password"
        placeholder="Password"
        className="form-control w-75 mb-4"
        value={password}
        onChange={handleSetPassword}
        minLength={8}
        required
      />

      <button
        type="submit"
        className="btn btn-accent px-5"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Registering..." : "Create"}
      </button>

      <span className="mt-3">{message}</span>
    </form>
  );
}

export default RegisterForm;
