export function validarCNPJ(cnpj: string): boolean {
  return /^[0-9]{14}$/.test(cnpj);
}
