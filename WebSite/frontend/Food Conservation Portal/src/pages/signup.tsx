import axios from 'axios';
import React, { useEffect, useState } from 'react';
import { useNavigate, type NavigateFunction } from 'react-router-dom';

type UserRole = 'GOVT' | 'SUPPLIER' | 'NGO' | 'LOGISTICS' | '';

interface UserRegistrationData {
  role: UserRole;
  username: string;
  password: string;
  first_name: string;
  last_name: string;
  address: string;
  contact_number: number | null;
}

interface ApiResponse {
  code: number;
  message: string;
}

export default function App() {
  // Form state
  const [formData, setFormData] = useState<UserRegistrationData>({
    role: '',
    username: '',
    password: '',
    first_name: '',
    last_name: '',
    address: '',
    contact_number: null
  });

  // Response state
  const [response, setResponse] = useState<ApiResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  // Handle input changes
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    
    // Convert contact_number to number
    if (name === 'contact_number') {
      setFormData(prev => ({
        ...prev,
        [name]: value === '' ? 0 : Number(value)
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };

  // Handle Password verification
  const [confirmPassword, setConfirmPassword] = useState<string>('');
  const [passMatch, setPassMatch] = useState<boolean>(true);
  const [isSubmit,setSubmit] = useState<boolean>(false);
  
  useEffect(() => { 
      if (confirmPassword == formData.password){
      setPassMatch(false); 
      setSubmit(true);
    } else { 
      setPassMatch(true);
    }
  }, [confirmPassword]);

  function handlePassword(e: { target: { value: React.SetStateAction<string>; }; }){
    setConfirmPassword(e.target.value)
    console.log(confirmPassword,formData.password,`{confirmPassword == formData.password}`)
  }

  // Handle form submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setResponse(null);
    
    try {
      const response = await axios.post(
        'http://localhost:8000/signup',
        formData
      );

      // Axios wraps response in data property
      setResponse(response.data);
    } catch (error: any) {
      if (error.response) {
        // The server responded with a status code outside the 2xx range
        setResponse(error.response.data);
      } else {
        setResponse({
          code: 500,
          message: error.message || 'An unexpected error occurred'
        });
      }
    } finally {
      setIsLoading(false);
    }
  };

  // Get registration status message
  const getStatusMessage = () => {
    if (!response) return null;
    
    if (response.code === 100) {
      return "Registration failed. Please check your information and try again. User might already exist";
    } else if (response.code === 500) {
      return "An unknown error occurred. Please try again later.";
    } else {
      return `Registration successful! Your user ID is: ${response.code}`;
    }
  };

  // Handle Login button click
  // Router navigation
  const navigate: NavigateFunction = useNavigate();
  const handleLoginClick = () => {
    navigate('/login');
  };

  // Get response status color
  const getStatusColor = () => {
    if (!response) return '';
    
    if (response.code === 100) {
      return 'bg-yellow-100 border-yellow-500 text-yellow-700';
    } else if (response.code === 500) {
      return 'bg-red-100 border-red-500 text-red-700';
    } else {
      return 'bg-green-100 border-green-500 text-green-700';
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
          User Registration
        </h2>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <form className="space-y-6" onSubmit={handleSubmit}>
            {/* Role Selection */}
            <div>
              <label htmlFor="role" className="block text-sm font-medium text-gray-700">
                Role
              </label>
              <select
                id="role"
                name="role"
                className="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
                value={formData.role}
                onChange={handleChange}
                required
              >
                <option value="GOVT">Government</option>
                <option value="SUPPLIER">Supplier</option>
                <option value="NGO">NGO</option>
                <option value="LOGISTICS">Logistics</option>
              </select>
            </div>

            {/* Username */}
            <div>
              <label htmlFor="username" className="block text-sm font-medium text-gray-700">
                Username
              </label>
              <input
                id="username"
                name="username"
                type="text"
                autoComplete="username"
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.username}
                onChange={handleChange}
              />
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="new-password"
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.password}
                onChange={handleChange}
              />
            </div>
            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
                Confirm Password
              </label>
              <input
                id="ConfirmPassword"
                name="ConfirmPassword"
                type="password"
                autoComplete="new-password"
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={confirmPassword === null ? '':confirmPassword}
                onChange={handlePassword}
              />
              {confirmPassword && passMatch &&
              <p className = {`text-red-400`}>The password did not match yet!</p>}
            </div>
            

            {/* First Name */}
            <div>
              <label htmlFor="first_name" className="block text-sm font-medium text-gray-700">
                First Name
              </label>
              <input
                id="first_name"
                name="first_name"
                type="text"
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.first_name}
                onChange={handleChange}
              />
            </div>

            {/* Last Name */}
            <div>
              <label htmlFor="last_name" className="block text-sm font-medium text-gray-700">
                Last Name
              </label>
              <input
                id="last_name"
                name="last_name"
                type="text"
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.last_name}
                onChange={handleChange}
              />
            </div>

            {/* Address */}
            <div>
              <label htmlFor="address" className="block text-sm font-medium text-gray-700">
                Address
              </label>
              <input
                id="address"
                name="address"
                type="text"
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.address}
                onChange={handleChange}
              />
            </div>

            {/* Contact Number */}
            <div>
              <label htmlFor="contact_number" className="block text-sm font-medium text-gray-700">
                Contact Number
              </label>
              <input
                id="contact_number"
                name="contact_number"
                type="number" 
                required
                className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.contact_number === null ? '' : formData.contact_number}
                onChange={handleChange}
              />
            </div>

            {/* Submit Button */}
            <div>
              {!isSubmit && <p>Please fill all field to register</p>}
              {isSubmit &&
              <button
                type="submit"
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                disabled={isLoading}
              >
                {isLoading ? 'Registering...' : 'Register'}
              </button>}
            </div>
          </form>

          {/* Registration Status Message */}
          {response && (
            <div className={`mt-6 p-4 border rounded-md ${getStatusColor()}`}>
              <p className="text-sm font-medium">{getStatusMessage()}</p>
              <p className="text-xs mt-1">Response code: {response.code}</p>
              <p className="text-xs mt-1">Message: {response.message}</p>
            </div>
          )}
          <div className = "mt-4">
           <button
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                onClick={handleLoginClick}
                disabled={isLoading}
              >
                {isLoading ? 'Loading...' : 'Login'}
              </button>
          </div>
        </div>
      </div>
    </div>
  );
}