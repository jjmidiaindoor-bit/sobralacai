import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { useSettings, useUpdateSettings } from "@/hooks/use-supabase";
import { toast } from "sonner";

export default function AdminSettings() {
  const { data: settings, isLoading } = useSettings();
  const updateSettings = useUpdateSettings();
  const [form, setForm] = useState({ 
    nome_loja: "", 
    telefone_whatsapp: "", 
    endereco: "", 
    logo_url: "",
    banner_url: "",
    slogan: ""
  });

  useEffect(() => {
    if (settings) {
      setForm({
        nome_loja: settings.nome_loja || "",
        telefone_whatsapp: settings.telefone_whatsapp || "",
        endereco: settings.endereco || "",
        logo_url: settings.logo_url || "",
        banner_url: settings.banner_url || "",
        slogan: settings.slogan || "",
      });
    }
  }, [settings]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!settings) {
      toast.error("Nenhuma configuração encontrada.");
      return;
    }
    try {
      await updateSettings.mutateAsync({ id: settings.id, ...form });
      toast.success("Configurações salvas com sucesso!");
    } catch (error: any) {
      console.error('Erro ao salvar:', error);
      toast.error(`Erro ao salvar: ${error?.message || 'Erro desconhecido'}`);
    }
  };

  if (isLoading) return <p className="font-heading text-sm uppercase text-muted-foreground">CARREGANDO...</p>;

  return (
    <div>
      <h2 className="font-heading text-xl uppercase mb-6">CONFIGURAÇÕES</h2>
      <div className="bg-card border-2 border-border p-6 max-w-lg">
        <form onSubmit={handleSave} className="space-y-4">
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">NOME DA LOJA</label>
            <input name="nome_loja" value={form.nome_loja} onChange={handleChange}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent transition-colors duration-100" />
          </div>
          
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">TELEFONE WHATSAPP</label>
            <input name="telefone_whatsapp" value={form.telefone_whatsapp} onChange={handleChange}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent transition-colors duration-100" 
              placeholder="(00) 00000-0000" />
          </div>
          
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">ENDEREÇO</label>
            <input name="endereco" value={form.endereco} onChange={handleChange}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent transition-colors duration-100" 
              placeholder="Rua, Número - Bairro" />
          </div>
          
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">URL DO LOGO</label>
            <input name="logo_url" value={form.logo_url} onChange={handleChange}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent transition-colors duration-100" 
              placeholder="https://..." />
          </div>
          
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">URL DO BANNER</label>
            <input name="banner_url" value={form.banner_url} onChange={handleChange}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent transition-colors duration-100" 
              placeholder="https://..." />
          </div>
          
          <div className="border-2 border-border p-4">
            <label className="font-heading text-xs uppercase block mb-2">SLOGAN</label>
            <input name="slogan" value={form.slogan} onChange={handleChange}
              className="w-full bg-transparent font-body text-sm outline-none border-b-2 border-border pb-1 focus:border-accent transition-colors duration-100" 
              placeholder="O melhor açaí da cidade" />
          </div>
          
          <Button type="submit" size="lg" className="w-full" disabled={updateSettings.isPending}>
            {updateSettings.isPending ? "SALVANDO..." : "SALVAR CONFIGURAÇÕES"}
          </Button>
        </form>
      </div>
    </div>
  );
}
