import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom'; // Add this import for toBeInTheDocument
import { BrowserRouter as Router } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from '../Redux/store';
import Navbar1 from './Navbar1';

// Mock the image files
jest.mock("./Images/Primelogo.svg", () => "mock-primelogo.svg");
jest.mock("./Images/Nav1_Language.svg", () => "mock-language-logo.svg");

// Mock the HomepageBeforeLogin component with proper structure
jest.mock('./HomepageBeforeLogin', () => ({
  __esModule: true,
  Homepage: '/mock-homepage'
}));

// Suppress React Router future flag warnings
beforeAll(() => {
  jest.spyOn(console, 'warn').mockImplementation(() => {});
});

describe('Navbar1 Component', () => {
  test('renders Prime logo', () => {
    render(
      <Router>
        <Provider store={store}>
          <Navbar1 />
        </Provider>
      </Router>
    );
    
    const logoElement = screen.getByAltText(/prime logo/i);
    expect(logoElement).toBeInTheDocument();
  });

  test('has sign in link', () => {
    render(
      <Router>
        <Provider store={store}>
          <Navbar1 />
        </Provider>
      </Router>
    );
    
    const signInLink = screen.getByRole('link', { name: /sign in/i });
    expect(signInLink).toBeInTheDocument();
  });
});