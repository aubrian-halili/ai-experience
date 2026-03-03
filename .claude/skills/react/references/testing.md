# React Testing Reference

## RTL Query Priority

Always use the most accessible query available. This order matches how users interact with your UI.

| Priority | Query | When to Use |
|----------|-------|-------------|
| 1 | `getByRole` | Buttons, links, headings, form elements — almost everything |
| 2 | `getByLabelText` | Form fields with associated labels |
| 3 | `getByPlaceholderText` | Inputs where label is not visible |
| 4 | `getByText` | Non-interactive elements by visible text |
| 5 | `getByDisplayValue` | Filled-in form elements |
| 6 | `getByAltText` | Images |
| 7 | `getByTitle` | Elements with `title` attribute |
| 8 | `getByTestId` | Last resort — no semantic way to query |

## Component Testing Patterns

### Basic Component Test

```tsx
import { render, screen } from '@testing-library/react';
import { UserAvatar } from './UserAvatar';

describe('UserAvatar', () => {
  it('renders the avatar image with alt text', () => {
    render(<UserAvatar name="Jane Doe" imageUrl="/jane.jpg" />);

    const img = screen.getByAltText("Jane Doe's avatar");
    expect(img).toBeInTheDocument();
    expect(img).toHaveAttribute('src', '/jane.jpg');
  });

  it('applies the size class', () => {
    const { container } = render(
      <UserAvatar name="Jane Doe" imageUrl="/jane.jpg" size="lg" />,
    );

    expect(container.firstChild).toHaveClass('avatar--lg');
  });

  it('defaults to medium size', () => {
    const { container } = render(
      <UserAvatar name="Jane Doe" imageUrl="/jane.jpg" />,
    );

    expect(container.firstChild).toHaveClass('avatar--md');
  });
});
```

### Async Component Test

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import { UserProfile } from './UserProfile';

// Mock the hook at the module level
jest.mock('./usersApi', () => ({
  useGetUserQuery: jest.fn(),
}));

import { useGetUserQuery } from './usersApi';

describe('UserProfile', () => {
  it('shows loading state', () => {
    (useGetUserQuery as jest.Mock).mockReturnValue({
      data: undefined,
      isLoading: true,
    });

    render(<UserProfile userId="1" />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('renders user data when loaded', () => {
    (useGetUserQuery as jest.Mock).mockReturnValue({
      data: { id: '1', name: 'Jane Doe', email: 'jane@example.com' },
      isLoading: false,
    });

    render(<UserProfile userId="1" />);
    expect(screen.getByRole('heading', { name: 'Jane Doe' })).toBeInTheDocument();
    expect(screen.getByText('jane@example.com')).toBeInTheDocument();
  });

  it('shows error message on failure', () => {
    (useGetUserQuery as jest.Mock).mockReturnValue({
      data: undefined,
      isLoading: false,
      error: { status: 500, data: 'Server error' },
    });

    render(<UserProfile userId="1" />);
    expect(screen.getByRole('alert')).toHaveTextContent(/failed to load/i);
  });
});
```

### Form Interaction Test

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  it('submits with email and password', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockOnSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'jane@example.com');
    await user.type(screen.getByLabelText(/password/i), 'secret123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(mockOnSubmit).toHaveBeenCalledWith({
      email: 'jane@example.com',
      password: 'secret123',
    });
  });

  it('shows validation error for empty email', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockOnSubmit} />);

    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  it('disables submit button while submitting', async () => {
    const user = userEvent.setup();
    mockOnSubmit.mockImplementation(
      () => new Promise((resolve) => setTimeout(resolve, 100)),
    );

    render(<LoginForm onSubmit={mockOnSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'jane@example.com');
    await user.type(screen.getByLabelText(/password/i), 'secret123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(screen.getByRole('button', { name: /sign in/i })).toBeDisabled();
  });
});
```

### Custom Hook Test

```tsx
import { renderHook, act } from '@testing-library/react';
import { useForm } from './useForm';

describe('useForm', () => {
  const initialValues = { name: '', email: '' };

  it('initializes with provided values', () => {
    const { result } = renderHook(() => useForm(initialValues));

    expect(result.current.values).toEqual({ name: '', email: '' });
    expect(result.current.errors).toEqual({});
    expect(result.current.touched).toEqual({});
  });

  it('updates values on change', () => {
    const { result } = renderHook(() => useForm(initialValues));

    act(() => {
      result.current.handleChange('name')({
        target: { value: 'Jane' },
      } as React.ChangeEvent<HTMLInputElement>);
    });

    expect(result.current.values.name).toBe('Jane');
  });

  it('resets to initial values', () => {
    const { result } = renderHook(() => useForm(initialValues));

    act(() => {
      result.current.handleChange('name')({
        target: { value: 'Jane' },
      } as React.ChangeEvent<HTMLInputElement>);
    });

    act(() => {
      result.current.reset();
    });

    expect(result.current.values).toEqual(initialValues);
  });
});
```

## Redux Testing Patterns

### Slice Reducer Tests

```tsx
import cartReducer, {
  addItem,
  removeItem,
  updateQuantity,
  clearCart,
} from './cartSlice';
import type { CartState } from './cartSlice';

describe('cartSlice', () => {
  const initialState: CartState = { items: [], promoCode: null };

  it('adds a new item', () => {
    const item = { productId: '1', name: 'Widget', price: 9.99 };
    const state = cartReducer(initialState, addItem(item));

    expect(state.items).toHaveLength(1);
    expect(state.items[0]).toEqual({ ...item, quantity: 1 });
  });

  it('increments quantity for existing item', () => {
    const item = { productId: '1', name: 'Widget', price: 9.99 };
    let state = cartReducer(initialState, addItem(item));
    state = cartReducer(state, addItem(item));

    expect(state.items).toHaveLength(1);
    expect(state.items[0].quantity).toBe(2);
  });

  it('removes an item by productId', () => {
    const item = { productId: '1', name: 'Widget', price: 9.99 };
    let state = cartReducer(initialState, addItem(item));
    state = cartReducer(state, removeItem('1'));

    expect(state.items).toHaveLength(0);
  });

  it('resets to initial state on clearCart', () => {
    const item = { productId: '1', name: 'Widget', price: 9.99 };
    let state = cartReducer(initialState, addItem(item));
    state = cartReducer(state, clearCart());

    expect(state).toEqual(initialState);
  });
});
```

### Selector Tests

```tsx
import { selectCartTotal, selectCartItemCount } from './cartSelectors';
import type { RootState } from '../store';

describe('cart selectors', () => {
  const mockState = {
    cart: {
      items: [
        { productId: '1', name: 'Widget', quantity: 2, price: 10 },
        { productId: '2', name: 'Gadget', quantity: 1, price: 25 },
      ],
      promoCode: null,
    },
  } as RootState;

  it('calculates the cart total', () => {
    expect(selectCartTotal(mockState)).toBe(45);
  });

  it('counts total items', () => {
    expect(selectCartItemCount(mockState)).toBe(3);
  });
});
```

## RTK Query Testing Patterns

### MSW Setup

```tsx
// src/mocks/handlers.ts
import { rest } from 'msw';

export const handlers = [
  rest.get('/api/users', (_req, res, ctx) => {
    return res(
      ctx.json([
        { id: '1', name: 'Jane Doe', email: 'jane@example.com' },
        { id: '2', name: 'John Smith', email: 'john@example.com' },
      ]),
    );
  }),

  rest.post('/api/users', async (req, res, ctx) => {
    const body = await req.json();
    return res(ctx.status(201), ctx.json({ id: '3', ...body }));
  }),

  rest.delete('/api/users/:id', (_req, res, ctx) => {
    return res(ctx.status(204));
  }),
];

// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

### Jest Setup for MSW

```tsx
// src/setupTests.ts
import '@testing-library/jest-dom';
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Connected Component Test with RTK Query

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { server } from '../../mocks/server';
import { renderWithStore } from '../../test-utils';
import { UserList } from './UserList';

describe('UserList', () => {
  it('renders users from API', async () => {
    renderWithStore(<UserList />);

    expect(screen.getByRole('progressbar')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('Jane Doe')).toBeInTheDocument();
      expect(screen.getByText('John Smith')).toBeInTheDocument();
    });
  });

  it('handles API error', async () => {
    server.use(
      rest.get('/api/users', (_req, res, ctx) => {
        return res(ctx.status(500));
      }),
    );

    renderWithStore(<UserList />);

    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
    });
  });

  it('deletes a user and refreshes list', async () => {
    const user = userEvent.setup();
    renderWithStore(<UserList />);

    await waitFor(() => {
      expect(screen.getByText('Jane Doe')).toBeInTheDocument();
    });

    await user.click(
      screen.getAllByRole('button', { name: /delete/i })[0],
    );

    await waitFor(() => {
      expect(screen.queryByText('Jane Doe')).not.toBeInTheDocument();
    });
  });
});
```

### Mutation Test

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { renderWithStore } from '../../test-utils';
import { CreateUserForm } from './CreateUserForm';

describe('CreateUserForm', () => {
  it('creates a user and clears the form', async () => {
    const user = userEvent.setup();
    renderWithStore(<CreateUserForm />);

    await user.type(screen.getByLabelText(/name/i), 'New User');
    await user.type(screen.getByLabelText(/email/i), 'new@example.com');
    await user.click(screen.getByRole('button', { name: /create/i }));

    await waitFor(() => {
      expect(screen.getByLabelText(/name/i)).toHaveValue('');
    });
  });
});
```

## Test Utilities

### renderWithStore

```tsx
// src/test-utils.tsx
import { render, RenderOptions } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore, PreloadedState } from '@reduxjs/toolkit';
import { usersApi } from './services/usersApi';
import cartReducer from './features/cart/cartSlice';
import type { RootState } from './app/store';

interface ExtendedRenderOptions extends Omit<RenderOptions, 'queries'> {
  preloadedState?: PreloadedState<RootState>;
}

export const renderWithStore = (
  ui: React.ReactElement,
  { preloadedState, ...renderOptions }: ExtendedRenderOptions = {},
) => {
  const store = configureStore({
    reducer: {
      cart: cartReducer,
      [usersApi.reducerPath]: usersApi.reducer,
    },
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware().concat(usersApi.middleware),
    preloadedState,
  });

  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <Provider store={store}>{children}</Provider>
  );

  return {
    store,
    ...render(ui, { wrapper: Wrapper, ...renderOptions }),
  };
};
```

### renderWithRedux (without RTK Query)

```tsx
export const renderWithRedux = (
  ui: React.ReactElement,
  { preloadedState, ...renderOptions }: ExtendedRenderOptions = {},
) => {
  const store = configureStore({
    reducer: { cart: cartReducer },
    preloadedState,
  });

  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <Provider store={store}>{children}</Provider>
  );

  return {
    store,
    ...render(ui, { wrapper: Wrapper, ...renderOptions }),
  };
};
```

## Common Testing Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using `getByTestId` first | Ignores accessibility, brittle | Use `getByRole` or `getByLabelText` |
| Testing implementation details | Tests break on refactor | Test user-visible behavior only |
| Snapshot tests for components | False positives, noisy diffs | Write explicit assertions |
| Not wrapping state updates in `act` | React warnings, flaky tests | Use `userEvent` (wraps `act` automatically) |
| Using `fireEvent` instead of `userEvent` | Misses real browser behavior | `userEvent.setup()` simulates full interaction |
| Not waiting for async operations | Tests pass with stale state | Use `waitFor` or `findBy` queries |
| Mocking too much | Tests don't catch integration bugs | Mock at network boundary (MSW), not internal modules |
| Testing Redux store directly in component tests | Couples tests to implementation | Test via UI behavior; test slices separately |
| Forgetting to reset MSW handlers | Test pollution | `afterEach(() => server.resetHandlers())` |
| Not testing error states | Bugs in error UI go unnoticed | Always test loading, success, and error states |
