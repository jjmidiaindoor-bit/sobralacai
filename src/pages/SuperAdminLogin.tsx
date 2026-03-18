import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";

export default function SuperAdminLogin() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Buscar loja pelo email e senha (Super Admin)
      const { data: loja, error } = await supabase
        .from("lojas")
        .select("*")
        .eq("email_admin", email)
        .eq("senha_admin", password)
        .eq("ativa", true)
        .single();

      if (error || !loja) {
        toast.error("Email ou senha incorretos.");
        setLoading(false);
        return;
      }

      // Verificar se é Super Admin (email específico)
      if (email !== "super@acaiaqui.com") {
        toast.error("Acesso permitido apenas para Super Admin.");
        setLoading(false);
        return;
      }

      // Armazenar dados da loja no localStorage
      const lojaData = {
        id: loja.id,
        nome_loja: loja.nome_loja,
        email_admin: loja.email_admin,
        nome_admin: loja.nome_admin,
        is_super_admin: true
      };
      localStorage.setItem("super_admin", JSON.stringify(lojaData));

      // Configurar o email da loja no Supabase para RLS
      supabase.rpc('set_loja_email', { loja_email: loja.email_admin });

      toast.success("Login realizado!");
      navigate("/super-admin/lojas");
    } catch (err) {
      console.error("Erro no login:", err);
      toast.error("Erro ao fazer login. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-primary flex items-center justify-center p-4">
      <div className="w-full max-w-sm bg-card p-8 border-2 border-border">
        <h1 className="font-heading text-2xl uppercase text-center mb-2">SUPER ADMIN</h1>
        <p className="text-center text-muted-foreground text-sm mb-8 font-body">Painel de Controle</p>
        <form onSubmit={handleLogin} className="space-y-4">
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">EMAIL</label>
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent" required />
          </div>
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">SENHA</label>
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent" required />
          </div>
          <Button type="submit" size="lg" className="w-full" disabled={loading}>
            {loading ? "ENTRANDO..." : "ENTRAR"}
          </Button>
        </form>
      </div>
    </div>
  );
}
