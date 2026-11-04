import { useState } from "react";
import axios from "axios";
import {
  API_BASE_URL,
  getApiErrorMessage,
  getAuthToken,
} from "../utils/bookApi.ts";
import type { Book } from "../types/book.ts";

type DeleteBookProps = {
  book: Book;
  onConfirm: () => void;
  onCancel: () => void;
};

export default function DeleteBook({
  book,
  onConfirm,
  onCancel,
}: DeleteBookProps) {
  const [message, setMessage] = useState("");
  const [isDeleting, setIsDeleting] = useState(false);

  async function handleDelete() {
    if (isDeleting) return;

    setIsDeleting(true);
    setMessage("");

    try {
      const response = await axios.post(`${API_BASE_URL}/library/delete`, {
        book_id: book.id,
        token: getAuthToken(),
      });

      if (response.data?.status !== "success") {
        throw new Error(
          response.data?.reason || "The book could not be deleted.",
        );
      }

      onConfirm();
    } catch (error) {
      setMessage(getApiErrorMessage(error, "Unable to delete the book."));
    } finally {
      setIsDeleting(false);
    }
  }

  return (
    <div
      className="book-dialog-backdrop"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget && !isDeleting) onCancel();
      }}
    >
      <section
        className="book-dialog bg-base shadow-lg p-4 p-md-5 text-center"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="delete-book-heading"
      >
        <h2 id="delete-book-heading" className="font-kurale mb-3">
          Delete Book
        </h2>

        {message && (
          <p className="text-danger mb-3" role="alert">
            {message}
          </p>
        )}

        <div className="d-flex justify-content-center gap-3">
          <button
            type="button"
            className="btn btn-outline-dark"
            onClick={onCancel}
            disabled={isDeleting}
          >
            Cancel
          </button>
          <button
            type="button"
            className="btn btn-dark"
            onClick={handleDelete}
            disabled={isDeleting}
          >
            {isDeleting ? "Deleting..." : "Confirm"}
          </button>
        </div>
      </section>
    </div>
  );
}
