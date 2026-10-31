import { useState, type FormEvent } from "react";
import type { Book } from "./AddBook";

type EditBookProps = {
  book: Book;
  onSave: (book: Book) => void;
  onCancel: () => void;
};

export default function EditBook({ book, onSave, onCancel }: EditBookProps) {
  const [title, setTitle] = useState(book.title);
  const [author, setAuthor] = useState(book.author);
  const [genre, setGenre] = useState(book.genre);
  const [year, setYear] = useState(String(book.year));
  const [description, setDescription] = useState(book.description ?? "");
  const [coverImageUrl, setCoverImageUrl] = useState(book.coverImageUrl ?? "");

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const publicationYear = Number(year);

    if (
      !title.trim() ||
      !author.trim() ||
      !genre.trim() ||
      !year ||
      !description.trim() ||
      !Number.isInteger(publicationYear) ||
      publicationYear < 1
    ) {
      return;
    }

    onSave({
      ...book,
      title: title.trim(),
      author: author.trim(),
      genre: genre.trim(),
      year: publicationYear,
      description: description.trim(),
      coverImageUrl: coverImageUrl.trim(),
    });
  }

  return (
    <div
      className="book-dialog-backdrop"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) onCancel();
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
            required
          />

          <input
            className="form-control book-input"
            aria-label="Book genre"
            placeholder="Genre"
            value={genre}
            onChange={(event) => setGenre(event.target.value)}
            required
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
            required
          />

          <textarea
            className="form-control book-input"
            aria-label="Book description"
            placeholder="Description"
            rows={3}
            value={description}
            onChange={(event) => setDescription(event.target.value)}
            required
          />

          <input
            className="form-control book-input"
            aria-label="Book cover image URL"
            placeholder="Cover Image URL"
            type="url"
            value={coverImageUrl}
            onChange={(event) => setCoverImageUrl(event.target.value)}
          />

          <div className="d-flex justify-content-center gap-3 mt-2">
            <button
              type="button"
              className="btn btn-outline-dark"
              onClick={onCancel}
            >
              Cancel
            </button>
            <button type="submit" className="btn btn-dark">
              Confirm
            </button>
          </div>
        </form>
      </section>
    </div>
  );
}
