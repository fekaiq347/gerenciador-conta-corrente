/** @type {import("tailwindcss").Config} */
module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js"
  ],
  theme: {
    extend: {
      // Se quiser adicionar cores, fontes ou espaçamentos, faça aqui
    },
  },
  plugins: [
    // Exemplo de plugins:
    require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
  ],
}

