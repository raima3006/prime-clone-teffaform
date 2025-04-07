import { configureStore } from '@reduxjs/toolkit';
import { reducerR } from './reducer';  // Named import

const store = configureStore({
  reducer: reducerR
});

export default store;