import { BrowserRouter, Route, Routes } from 'react-router-dom';
import Test from './pages/test';
import SignupForm from './pages/signup';
import Supplier from './pages/supplier';
import Login from './pages/login';

export const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path = '/' element = {<Test />}></ Route>
        <Route path = '/signup' element = {<SignupForm />}></ Route>
        <Route path = '/login' element = {<Login />}></ Route>
        <Route path = '/supplier' element = {<Supplier />}></ Route>
      </Routes>
    </BrowserRouter>
    
  )
}

export default App;