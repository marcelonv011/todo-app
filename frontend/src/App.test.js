import { render, screen } from '@testing-library/react';
import axios from 'axios';
import App from './App';

jest.mock('axios');

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
  expect(screen.getByRole('button', { name: 'Adicionar' })).toBeInTheDocument();
});
