/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./lib/**/*.ml", "./bin/**/*.ml", "./static/**/*.html"],
    theme: {
        extend: {
            colors: {
                'asoiaf-dark': '#1a1a1a',
                'asoiaf-gold': '#c9b037',
                'asoiaf-green': '#6aaa64',
                'asoiaf-gray': '#787c7e',
            },
        },
    },
    plugins: [],
}
