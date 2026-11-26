import { render, screen } from '@testing-library/react';
import axios from 'axios';
import App from './App';

// Simular Axios sin cargar su modulo real
jest.mock('axios', () => ({
  get: jest.fn(),
  post: jest.fn(),
  patch: jest.fn(),
  delete: jest.fn(),
}));

test('muestra las tareas obtenidas de la API', async () => {
  axios.get.mockResolvedValue({
    data: [
      {
        _id: '1',
        text: 'Teste CI',
        completed: false,
      },
    ],
  });

  render(<App />);

  expect(await screen.findByText('Teste CI')).toBeInTheDocument();

  expect(
    screen.getByRole('button', { name: 'Adicionar' })
  ).toBeInTheDocument();
});
