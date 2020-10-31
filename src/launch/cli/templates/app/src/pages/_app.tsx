import React from 'react';
import { AppProps } from 'next/app'
import Navbar from '../components/Shared/Navbar';
import '../assets/styles/globals.scss';

function MyApp({ Component, pageProps }: AppProps) {
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
