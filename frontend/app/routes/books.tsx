import { useMemo, useState } from "react";
import AddBook, { type Book } from "../components/AddBook";
import EditBook from "../components/EditBook";
import DeleteBook from "../components/DeleteBook";
import "../sass/books.scss";

const startingBooks: Book[] = [
  {
    id: 1,
    title: "Super Awesome Book",
    author: "John Doe",
    genre: "Awesomeness",
    year: 2001,
    description: "Awesome book description",
    coverImageUrl: "",
  },
  {
    id: 2,
    title: "Even More Awesome Book",
    author: "Jane Doe",
    genre: "Even More Awesomeness",
    year: 2007,
    description: "Awesomer book description",
    coverImageUrl: "",
  },
  {
    id: 3,
    title: "Funny Placeholder Data",
    author: "John Placeholder",
    genre: "Placeholding",
    year: 1776,
    description: "Placeholding since 1776",
    coverImageUrl: "",
  },
];

type ActionMode = "edit" | "delete" | null;
type Dialog =
  | { type: "add" }
  | { type: "edit"; book: Book }
  | { type: "delete"; book: Book }
  | null;

export default function Books() {
  const [books, setBooks] = useState<Book[]>(startingBooks);
  const [search, setSearch] = useState("");
  const [actionMode, setActionMode] = useState<ActionMode>(null);
  const [dialog, setDialog] = useState<Dialog>(null);

  const filteredBooks = useMemo(() => {
    const searchText = search.trim().toLowerCase();
    if (!searchText) return books;

    return books.filter((book) =>
      [
        book.title,
        book.author,
        book.genre,
        String(book.year),
        book.description,
      ].some((value) => value.toLowerCase().includes(searchText)),
    );
  }, [books, search]);

  function addBook(details: Omit<Book, "id">) {
    setBooks((current) => {
      const nextId =
        current.reduce((largest, book) => Math.max(largest, book.id), 0) + 1;
      return [...current, { ...details, id: nextId }];
    });
    setDialog(null);
  }

  function saveBook(updatedBook: Book) {
    setBooks((current) =>
      current.map((book) => (book.id === updatedBook.id ? updatedBook : book)),
    );
    setDialog(null);
    setActionMode(null);
  }

  function removeBook(bookId: number) {
    setBooks((current) => current.filter((book) => book.id !== bookId));
    setDialog(null);
    setActionMode(null);
  }

  function handleBookClick(book: Book) {
    if (actionMode === "edit") {
      setDialog({ type: "edit", book });
    } else if (actionMode === "delete") {
      setDialog({ type: "delete", book });
    }
  }

  function toggleMode(mode: Exclude<ActionMode, null>) {
    setActionMode((current) => (current === mode ? null : mode));
  }

  return (
    <main className="books-page bg-base min-vh-100 w-100">
      <div className="books-main container border-start border-end shadow-lg mx-auto px-4 px-md-5 pt-5 min-vh-100 w-75">
        <div className="d-flex justify-content-end mb-3">
          <button
            type="button"
            className="btn rounded-pill px-4 bg-white border border-2 border-dark text-dark"
          >
            Logout
          </button>
        </div>
        <h1 className="books-heading font-kurale text-center mb-4">Books</h1>

        <div className="books-toolbar d-flex flex-wrap align-items-center justify-content-center gap-2 mb-4">
          <input
            className="form-control books-search-input"
            type="search"
            aria-label="Search books"
            placeholder="Search books"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
          />

          <button
            type="button"
            className={`books-icon-button ${actionMode === "delete" ? "is-active" : ""}`}
            aria-label="Delete a book"
            aria-pressed={actionMode === "delete"}
            title="Select a book to delete"
            onClick={() => toggleMode("delete")}
          >
            🗑️
          </button>
          <button
            type="button"
            className="books-icon-button"
            aria-label="Add a book"
            title="Add a book"
            onClick={() => {
              setActionMode(null);
              setDialog({ type: "add" });
            }}
          >
            ➕
          </button>
          <button
            type="button"
            className={`books-icon-button ${actionMode === "edit" ? "is-active" : ""}`}
            aria-label="Edit a book"
            aria-pressed={actionMode === "edit"}
            title="Select a book to edit"
            onClick={() => toggleMode("edit")}
          >
            ✏️
          </button>
        </div>

        {actionMode && (
          <p className="books-action-hint text-center mb-3" role="status">
            {actionMode === "edit"
              ? "Select a book below to edit it. Click the pencil again to cancel."
              : "Select a book below to delete it. Click the trash can again to cancel."}
          </p>
        )}

        <section className="books-list mx-auto" aria-label="Book list">
          {filteredBooks.length > 0 ? (
            filteredBooks.map((book) => (
              <article
                className={`book-list-item ${actionMode ? "book-list-item--action" : ""}`}
                key={book.id}
              >
                {actionMode ? (
                  <button
                    type="button"
                    className="book-list-item__select"
                    onClick={() => handleBookClick(book)}
                  >
                    <img
                      className="book-list-item__cover"
                      src={
                        book.coverImageUrl.trim() ||
                        `${import.meta.env.BASE_URL}DefaultBook.png`
                      }
                      alt={`Cover of ${book.title}`}
                    />

                    <span className="book-list-item__text">
                      <span className="book-list-item__title">
                        {book.title}
                      </span>

                      <span className="book-list-item__details">
                        {book.author} · {book.genre} · {book.year}
                      </span>

                      <span className="book-list-item__description">
                        {book.description}
                      </span>
                    </span>
                  </button>
                ) : (
                  <div className="book-list-item__content">
                    <img
                      className="book-list-item__cover"
                      src={
                        book.coverImageUrl.trim() ||
                        `${import.meta.env.BASE_URL}DefaultBook.png`
                      }
                      alt={`Cover of ${book.title}`}
                    />

                    <div className="book-list-item__text">
                      <span className="book-list-item__title">
                        {book.title}
                      </span>

                      <span className="book-list-item__details">
                        {book.author} · {book.genre} · {book.year}
                      </span>

                      <span className="book-list-item__description">
                        {book.description}
                      </span>
                    </div>
                  </div>
                )}
              </article>
            ))
          ) : (
            <p className="text-center py-4 mb-0">
              No books found. Try another search.
            </p>
          )}
        </section>

        <p className="books-note text-center mt-4">
          Book changes are temporary and reset when you refresh the page.
        </p>
      </div>

      {dialog?.type === "add" && (
        <AddBook onAdd={addBook} onCancel={() => setDialog(null)} />
      )}
      {dialog?.type === "edit" && (
        <EditBook
          key={dialog.book.id}
          book={dialog.book}
          onSave={saveBook}
          onCancel={() => setDialog(null)}
        />
      )}
      {dialog?.type === "delete" && (
        <DeleteBook
          book={dialog.book}
          onConfirm={() => removeBook(dialog.book.id)}
          onCancel={() => setDialog(null)}
        />
      )}
    </main>
  );
}
