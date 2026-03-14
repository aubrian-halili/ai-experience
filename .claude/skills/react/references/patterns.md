# React Patterns Reference

## Component Patterns

### Simple Functional Component

```tsx
interface UserAvatarProps {
  name: string;
  imageUrl: string;
  size?: 'sm' | 'md' | 'lg';
}

export const UserAvatar = ({ name, imageUrl, size = 'md' }: UserAvatarProps) => {
  return (
    <div className={`avatar avatar--${size}`}>
      <img src={imageUrl} alt={`${name}'s avatar`} />
    </div>
  );
};
```

### Compound Component Pattern

Use when a component has tightly coupled sub-components that share implicit state.

```tsx
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextValue | null>(null);

const useTabsContext = () => {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tab components must be used within <Tabs>');
  return context;
};

export const Tabs = ({ defaultTab, children }: TabsProps) => {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div role="tablist">{children}</div>
    </TabsContext.Provider>
  );
};

Tabs.Tab = ({ id, children }: TabProps) => {
  const { activeTab, setActiveTab } = useTabsContext();
  return (
    <button
      role="tab"
      aria-selected={activeTab === id}
      onClick={() => setActiveTab(id)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = ({ id, children }: TabPanelProps) => {
  const { activeTab } = useTabsContext();
  if (activeTab !== id) return null;
  return <div role="tabpanel">{children}</div>;
};
```

### Container / Presentational Split

Use when the same UI needs different data sources or when data fetching is complex.

```tsx
// UserList.tsx — presentational (pure)
interface UserListProps {
  users: User[];
  isLoading: boolean;
  onSelect: (userId: string) => void;
}

export const UserList = ({ users, isLoading, onSelect }: UserListProps) => {
  if (isLoading) return <Spinner />;
  return (
    <ul>
      {users.map((user) => (
        <li key={user.id} onClick={() => onSelect(user.id)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
};

// UserListContainer.tsx — data fetching
export const UserListContainer = () => {
  const { data: users = [], isLoading } = useGetUsersQuery();
  const navigate = useNavigate();
  return (
    <UserList
      users={users}
      isLoading={isLoading}
      onSelect={(id) => navigate(`/users/${id}`)}
    />
  );
};
```

## Custom Hook Patterns

### Form Hook

```tsx
export const useForm = <T extends Record<string, unknown>>(initialValues: T) => {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});

  const handleChange = (field: keyof T) => (
    e: React.ChangeEvent<HTMLInputElement>,
  ) => {
    setValues((prev) => ({ ...prev, [field]: e.target.value }));
  };

  const handleBlur = (field: keyof T) => () => {
    setTouched((prev) => ({ ...prev, [field]: true }));
  };

  const reset = () => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
  };

  return { values, errors, touched, handleChange, handleBlur, setErrors, reset };
};
```

### Dependency Array Rules

| Situation | Rule |
|-----------|------|
| Primitive value (string, number, boolean) | Include directly — stable reference |
| Object or array | Memoize with `useMemo` or move inside the effect |
| Function | Wrap with `useCallback` or move inside the effect |
| Ref (`.current`) | Never include — refs are stable |
| Dispatch (Redux) | Safe to include — stable reference |

### Memoization Decision Guide

```
Should I memoize?
├─ Is the component re-rendering with the same props?
│  ├─ Yes → Is the render expensive (>16ms)?
│  │  ├─ Yes → Use React.memo on the component
│  │  └─ No → Don't memoize (overhead > benefit)
│  └─ No → Props are changing, memo won't help
├─ Is a computed value expensive?
│  ├─ Yes → useMemo
│  └─ No → Compute inline
└─ Is a callback causing child re-renders?
   ├─ Yes, child is memoized → useCallback
   └─ No → Skip useCallback
```

## Redux Toolkit Patterns

### Slice Structure

```tsx
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CartItem {
  productId: string;
  name: string;
  quantity: number;
  price: number;
}

interface CartState {
  items: CartItem[];
  promoCode: string | null;
}

const initialState: CartState = {
  items: [],
  promoCode: null,
};

export const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    addItem: (state, action: PayloadAction<Omit<CartItem, 'quantity'>>) => {
      const existing = state.items.find(
        (item) => item.productId === action.payload.productId,
      );
      if (existing) {
        existing.quantity += 1;
      } else {
        state.items.push({ ...action.payload, quantity: 1 });
      }
    },
    removeItem: (state, action: PayloadAction<string>) => {
      state.items = state.items.filter(
        (item) => item.productId !== action.payload,
      );
    },
    clearCart: () => initialState,
  },
});

export const { addItem, removeItem, clearCart } = cartSlice.actions;
export default cartSlice.reducer;
```

### Typed Selectors with createSelector

```tsx
import { createSelector } from '@reduxjs/toolkit';
import type { RootState } from '../store';

const selectCartItems = (state: RootState) => state.cart.items;

export const selectCartTotal = createSelector([selectCartItems], (items) =>
  items.reduce((total, item) => total + item.price * item.quantity, 0),
);

export const selectCartItemCount = createSelector([selectCartItems], (items) =>
  items.reduce((count, item) => count + item.quantity, 0),
);
```

### Typed Store Hooks

```tsx
import { useDispatch, useSelector, TypedUseSelectorHook } from 'react-redux';
import type { RootState, AppDispatch } from './store';

export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

## RTK Query Patterns

### API Definition with Tag-Based Cache Invalidation

```tsx
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

interface User {
  id: string;
  name: string;
  email: string;
}

interface CreateUserRequest {
  name: string;
  email: string;
}

export const usersApi = createApi({
  reducerPath: 'usersApi',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['User'],
  endpoints: (builder) => ({
    getUsers: builder.query<User[], void>({
      query: () => '/users',
      providesTags: (result) =>
        result
          ? [
              ...result.map(({ id }) => ({ type: 'User' as const, id })),
              { type: 'User', id: 'LIST' },
            ]
          : [{ type: 'User', id: 'LIST' }],
    }),
    getUser: builder.query<User, string>({
      query: (id) => `/users/${id}`,
      providesTags: (_result, _error, id) => [{ type: 'User', id }],
    }),
    createUser: builder.mutation<User, CreateUserRequest>({
      query: (body) => ({ url: '/users', method: 'POST', body }),
      invalidatesTags: [{ type: 'User', id: 'LIST' }],
    }),
  }),
});

export const {
  useGetUsersQuery,
  useGetUserQuery,
  useCreateUserMutation,
} = usersApi;
```

### Store Configuration with RTK Query

```tsx
import { configureStore } from '@reduxjs/toolkit';
import { usersApi } from './services/usersApi';
import cartReducer from './features/cart/cartSlice';

export const store = configureStore({
  reducer: {
    cart: cartReducer,
    [usersApi.reducerPath]: usersApi.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(usersApi.middleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

## Feature Folder Structure

```
src/
├── app/
│   ├── store.ts              # configureStore
│   └── hooks.ts              # useAppDispatch, useAppSelector
├── features/
│   ├── auth/
│   │   ├── AuthProvider.tsx
│   │   ├── LoginForm.tsx
│   │   ├── LoginForm.test.tsx
│   │   ├── authSlice.ts
│   │   ├── authSlice.test.ts
│   │   └── auth.types.ts
│   ├── users/
│   │   ├── UserList.tsx
│   │   ├── UserList.test.tsx
│   │   ├── UserProfile.tsx
│   │   ├── UserProfile.test.tsx
│   │   ├── usersApi.ts
│   │   ├── usersApi.test.ts
│   │   └── users.types.ts
│   └── cart/
│       ├── Cart.tsx
│       ├── Cart.test.tsx
│       ├── CartItem.tsx
│       ├── cartSlice.ts
│       ├── cartSlice.test.ts
│       ├── cartSelectors.ts
│       └── cart.types.ts
├── components/               # Shared/generic components
│   ├── Button.tsx
│   ├── Button.test.tsx
│   ├── Modal.tsx
│   └── Spinner.tsx
├── hooks/                    # Shared hooks
│   ├── useDebounce.ts
│   ├── useMediaQuery.ts
│   └── useForm.ts
└── utils/                    # Pure utility functions
    ├── formatters.ts
    └── validators.ts
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| `useEffect` for derived state | Extra render cycle, sync bugs | Compute during render or use `useMemo` |
| `useEffect` to respond to events | Runs after render, not at event time | Call handler directly in event callback |
| State for values that don't affect render | Unnecessary re-renders | Use `useRef` instead |
| `useState` + `useEffect` for fetching | Boilerplate, race conditions, no caching | Use RTK Query or React Query |
| Prop drilling through 4+ levels | Brittle, hard to refactor | Extract to Redux slice or Context |
| `index` as `key` for dynamic lists | Incorrect reconciliation, subtle bugs | Use stable unique ID |
| Memoizing everything | Memory overhead, code complexity | Only memoize after profiling |
| Giant monolithic components | Hard to test, reuse, and maintain | Extract sub-components at logical boundaries |
| Mutating state directly | React won't detect changes | Use Immer (built into RTK) or spread operators |
| `// eslint-disable` on hook deps | Stale closures, bugs | Fix the dependency or restructure the hook |
