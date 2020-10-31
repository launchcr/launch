import React from 'react';
import Navbar from '../components/Shared/Navbar';
import '../assets/styles/globals.scss';

function MyApp({ Component, pageProps }) {
  return (
    <>
      <Navbar />
      <div className="content">
        <Component {...pageProps} />
      </div>
    </>
  );
}

export default MyApp;
