import { useState, type FormEvent } from "react";
import axios from "axios";
import {
  API_BASE_URL,
  getApiErrorMessage,
  getAuthToken,
} from "../utils/bookApi.ts";
import type { Book } from "../types/book.ts";

type EditBookProps = {
  book: Book;
  onSave: (book: Book) => void;
  onCancel: () => void;
};

export default function EditBook({ book, onSave, onCancel }: EditBookProps) {
  const [title, setTitle] = useState(book.title);
  const [author, setAuthor] = useState(book.author);
  const [genre, setGenre] = useState(book.genre);
  const [year, setYear] = useState(book.year === null ? "" : String(book.year));
  const [description, setDescription] = useState(book.description);
  const [coverImageUrl, setCoverImageUrl] = useState(book.coverImageUrl);
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

    const updatedBook: Book = {
      ...book,
      title: title.trim(),
      author: author.trim(),
      genre: genre.trim(),
      year: publicationYear,
      description: description.trim(),
      coverImageUrl: coverImageUrl.trim(),
    };

    try {
      const response = await axios.post(`${API_BASE_URL}/library/edit`, {
        book_id: book.id,
        title: updatedBook.title,
        author: updatedBook.author || null,
        genre: updatedBook.genre || null,
        publication_year: updatedBook.year,
        description: updatedBook.description || null,
        cover_image: updatedBook.coverImageUrl || null,
        token: getAuthToken(),
      });

      if (response.data?.status !== "success") {
        throw new Error(
          response.data?.reason || "The book could not be edited.",
        );
      }

      onSave(updatedBook);
    } catch (error) {
      setMessage(getApiErrorMessage(error, "Unable to edit the book."));
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
        aria-labelledby="edit-book-heading"
      >
        <h2 id="edit-book-heading" className="font-kurale text-center mb-4">
          Edit Book
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
              {isSubmitting ? "Saving..." : "Confirm"}
            </button>
          </div>
        </form>
      </section>
    </div>
  );
}
