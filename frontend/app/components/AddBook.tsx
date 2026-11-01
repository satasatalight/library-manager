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

export default function AddBook({ onCancel }: AddBookProps) {
  return (
    <div className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center bg-dark bg-opacity-50">
      <section
        className="bg-white rounded shadow p-4 text-center"
        role="dialog"
        aria-modal="true"
      >
        <h2>AddBook component to be added later</h2>

        <button
          type="button"
          className="btn btn-outline-dark mt-3"
          onClick={onCancel}
        >
          Close
        </button>
      </section>
    </div>
  );
}
