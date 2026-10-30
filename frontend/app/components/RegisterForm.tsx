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
  const [invalidEmail, setInvalidEmail] = useState(false);

  function handleSetFirstName(e: React.ChangeEvent<HTMLInputElement>): void {
    setFirstName(e.target.value);
  }

  function handleSetLastName(e: React.ChangeEvent<HTMLInputElement>): void {
    setLastName(e.target.value);
  }

  function handleSetEmail(e: React.ChangeEvent<HTMLInputElement>): void {
    setEmail(e.target.value);
    setInvalidEmail(false);
    setMessage("");
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

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(email)) {
      setInvalidEmail(true);
      setMessage("Invalid email format.");
      return;
    }

    setInvalidEmail(false);

    if (!firstName.trim() || !lastName.trim() || password.length < 8) {
      setMessage(
        "Please fill in all fields and use a password of at least 8 characters.",
      );
      return;
    }

    setMessage("");
    setIsSubmitting(true);

    try {
      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/register",
        {
          first_name: firstName,
          last_name: lastName,
          email: email,
          password: password,
        },
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
      noValidate
    >
      <h2 className="mb-4">Create Account</h2>

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
        className={`form-control w-75 mb-4 ${invalidEmail ? "is-invalid" : ""}`}
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
        {isSubmitting ? "Creating Account..." : "Create"}
      </button>

      {message && <p className="mt-3 text-danger text-center">{message}</p>}
    </form>
  );
}

export default RegisterForm;
