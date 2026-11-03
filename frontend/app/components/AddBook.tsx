import { useState, type FormEvent } from "react";
import axios from "axios";
import {
  API_BASE_URL,
  getApiErrorMessage,
  getAuthToken,
} from "../utils/bookApi.ts";
import type { Book } from "../types/book.ts";

export type { Book } from "../types/book.ts";

type AddBookProps = {
  onAdd: (book: Book) => void;
  onCancel: () => void;
};

export default function AddBook({ onAdd, onCancel }: AddBookProps) {
  const [title, setTitle] = useState("");
  const [author, setAuthor] = useState("");
  const [genre, setGenre] = useState("");
  const [year, setYear] = useState("");
  const [description, setDescription] = useState("");
  const [coverImageUrl, setCoverImageUrl] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const publicationYear = year.trim() ? Number(year) : null;

    if (!title.trim()) {
      setMessage("Please give the book a title.");
      return;
    }

    if (
      publicationYear !== null &&
      (!Number.isInteger(publicationYear) || publicationYear < 1)
    ) {
      setMessage("Please enter a valid publication year.");
      return;
    }

    if (isSubmitting) return;

    setIsSubmitting(true);
    setMessage("");

    try {
      const response = await axios.post(`${API_BASE_URL}/library/add`, {
        title: title.trim(),
        author: author.trim() || null,
        genre: genre.trim() || null,
        publication_year: publicationYear,
        description: description.trim() || null,
        cover_image: coverImageUrl.trim() || null,
        token: getAuthToken(),
      });

      const data = response.data;

      if (
        data?.status !== "success" ||
        !Number.isFinite(Number(data.book_id))
      ) {
        throw new Error(data?.reason || "The book could not be added.");
      }

      onAdd({
        id: Number(data.book_id),
        title: title.trim(),
        author: author.trim(),
        genre: genre.trim(),
        year: publicationYear,
        description: description.trim(),
        coverImageUrl: coverImageUrl.trim(),
      });
    } catch (error) {
      setMessage(getApiErrorMessage(error, "Unable to add the book."));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div
      className="book-dialog-backdrop"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget && !isSubmitting) onCancel();
      }}
    >
      <section
        className="book-dialog bg-base shadow-lg p-4 p-md-5"
        role="dialog"
        aria-modal="true"
        aria-labelledby="add-book-heading"
      >
        <h2 id="add-book-heading" className="font-kurale text-center mb-4">
          Add Book
        </h2>

        <form onSubmit={handleSubmit} className="d-grid gap-3">
          <input
            className="form-control book-input"
            aria-label="Book title"
            placeholder="Title"
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            required
            autoFocus
          />

          <input
            className="form-control book-input"
            aria-label="Book author"
            placeholder="Author"
            value={author}
            onChange={(event) => setAuthor(event.target.value)}
          />

          <input
            className="form-control book-input"
            aria-label="Book genre"
            placeholder="Genre"
            value={genre}
            onChange={(event) => setGenre(event.target.value)}
          />

          <input
            className="form-control book-input"
            aria-label="Publication year"
            placeholder="Year of Release"
            type="number"
            min="1"
            max={new Date().getFullYear() + 1}
            value={year}
            onChange={(event) => setYear(event.target.value)}
          />

          <textarea
            className="form-control book-input"
            aria-label="Book description"
            placeholder="Description"
            rows={3}
            value={description}
            onChange={(event) => setDescription(event.target.value)}
          />

          <input
            className="form-control book-input"
            aria-label="Book cover image URL"
            placeholder="Cover Image URL"
            type="url"
            value={coverImageUrl}
            onChange={(event) => setCoverImageUrl(event.target.value)}
          />

          {message && (
            <p className="text-danger text-center mb-0" role="alert">
              {message}
            </p>
          )}

          <div className="d-flex justify-content-center gap-3 mt-2">
            <button
              type="button"
              className="btn btn-outline-dark"
              onClick={onCancel}
              disabled={isSubmitting}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="btn btn-dark"
              disabled={isSubmitting}
            >
              {isSubmitting ? "Adding..." : "Confirm"}
            </button>
          </div>
        </form>
      </section>
    </div>
  );
}
