export function validarCPF(cpf: string): boolean {
  return /^[0-9]{11}$/.test(cpf);
}
