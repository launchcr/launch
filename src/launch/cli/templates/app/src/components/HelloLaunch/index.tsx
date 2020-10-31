import React from 'react';

const HelloLaunch = ({ message }: { message: string }) => (
  <div style={{ textAlign: 'center' }}>
    <div className="alert alert-primary" role="alert">
      {message}
    </div>
    <h1>
      Welcome to Launch.cr
    </h1>
    <p>
      Learn
      {' '}
      <a href="https://github.com/sw-yx/react-typescript-cheatsheet">
        React + TypeScript
      </a>
      <br />
      <br />
      Learn
      {' '}
      <a href="https://crystal-lang.org/reference/getting_started/">
        Crystal
      </a>
    </p>
  </div>
);

export default HelloLaunch;
