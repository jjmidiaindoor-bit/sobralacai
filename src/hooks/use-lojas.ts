import { supabase } from "@/integrations/supabase/client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

export function useLojas() {
  return useQuery({
    queryKey: ["lojas"],
    queryFn: async () => {
      const { data, error } = await supabase.from("lojas").select("*").order("created_at", { ascending: false });
      if (error) throw error;
      return data || [];
    },
  });
}

export function useSaveLoja() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa }: any) => {
      if (id) {
        const { error } = await supabase.from('lojas').update({
          nome_loja, nome_admin, email_admin, telefone_whatsapp, endereco, ativa,
          updated_at: new Date().toISOString()
        }).eq('id', id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('lojas').insert({
          nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa
        });
        if (error) throw error;
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["lojas"] }),
  });
}

export function useDeleteLoja() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('lojas').delete().eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["lojas"] }),
  });
}

export function useAtivarDesativarLoja() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ativa }: { id: string; ativa: boolean }) => {
      const { error } = await supabase.from('lojas').update({ ativa: !ativa }).eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["lojas"] }),
  });
}

export function useChangeLojaPassword() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, novaSenha }: { id: string; novaSenha: string }) => {
      const { error } = await supabase.from('lojas').update({ senha_admin: novaSenha }).eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["lojas"] }),
  });
}
