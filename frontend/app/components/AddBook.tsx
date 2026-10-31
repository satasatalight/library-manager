import { useState, type FormEvent } from "react";

export type Book = {
  id: number;
  title: string;
  author: string;
  genre: string;
  year: number;
  description: string;
  coverImageUrl: string;
};

type AddBookProps = {
  onAdd: (book: Omit<Book, "id">) => void;
  onCancel: () => void;
};

export default function AddBook({ onAdd, onCancel }: AddBookProps) {
  const [title, setTitle] = useState("");
  const [author, setAuthor] = useState("");
  const [genre, setGenre] = useState("");
  const [year, setYear] = useState("");
  const [description, setDescription] = useState("");
  const [coverImageUrl, setCoverImageUrl] = useState("");

  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<Book[]>([]);
  const [isSearching, setIsSearching] = useState(false);

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

    onAdd({
      title: title.trim(),
      author: author.trim(),
      genre: genre.trim(),
      year: publicationYear,
      description: description.trim(),
      coverImageUrl: coverImageUrl.trim(),
    });
  }

  async function searchBooks() {
    if (!searchQuery.trim()) {
      setSearchResults([]);
      return;
    }

    setIsSearching(true);

    try {
      const response = await fetch(
        `/api/books/search?query=${encodeURIComponent(searchQuery)}`,
      );

      if (!response.ok) {
        throw new Error("Failed to search books");
      }

      const books: Book[] = await response.json();
      setSearchResults(books);
    } catch (error) {
      console.error("Error searching books:", error);
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
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
        aria-labelledby="add-book-heading"
      >
        <h2 id="add-book-heading" className="font-kurale text-center mb-4">
          Add Book
        </h2>

        <h5 className="font-kurale mb-2">Search Database</h5>

        <div className="mb-3">
          <div className="input-group">
            <input
              className="form-control book-input"
              aria-label="Search Our Database"
              placeholder="Search Our Database"
              value={searchQuery}
              onChange={(event) => setSearchQuery(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") {
                  event.preventDefault();
                  searchBooks();
                }
              }}
            />

            <button
              type="button"
              className="btn btn-dark"
              onClick={searchBooks}
              disabled={isSearching}
            >
              {isSearching ? "Searching..." : "Search"}
            </button>
          </div>

          {searchResults.length > 0 && (
            <div className="list-group mt-2">
              {searchResults.map((book) => (
                <button
                  key={book.id}
                  type="button"
                  className="list-group-item list-group-item-action"
                  onClick={() => {
                    setTitle(book.title);
                    setAuthor(book.author);
                    setGenre(book.genre);
                    setYear(String(book.year));
                    setDescription(book.description ?? "");
                    setCoverImageUrl(book.coverImageUrl ?? "");
                    setSearchResults([]);
                    setSearchQuery("");
                  }}
                >
                  <strong>{book.title}</strong>
                  <br />
                  <small>
                    {book.author} · {book.year}
                  </small>
                </button>
              ))}
            </div>
          )}

          {searchQuery.trim() !== "" &&
            !isSearching &&
            searchResults.length === 0 && (
              <p className="text-muted mt-2 mb-0">No books found.</p>
            )}
        </div>

        <h5 className="font-kurale mb-2">Add Manually</h5>

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
