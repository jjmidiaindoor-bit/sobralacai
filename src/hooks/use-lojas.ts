import { supabase } from "@/integrations/supabase/client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

export function useLojas() {
  return useQuery({
    queryKey: ["lojas"],
    queryFn: async () => {
      const { data, error } = await supabase.from("lojas").select("*").order("created_at", { ascending: false });
      if (error) {
        console.error('Erro ao buscar lojas:', error);
        return [];
      }
      return data || [];
    },
    retry: 2,
    staleTime: 1000 * 60 * 5, // 5 minutos
  });
}

export function useSaveLoja() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, nome_loja, nome_admin, email_admin, senha_admin, telefone_whatsapp, endereco, ativa }: any) => {
      console.log('[useSaveLoja] Salvando loja:', { id, email_admin });
      
      if (id) {
        // Update
        const payload: any = {
          nome_loja,
          nome_admin,
          email_admin,
          telefone_whatsapp,
          endereco,
          ativa,
          updated_at: new Date().toISOString()
        };
        
        if (senha_admin && senha_admin.trim() !== '') {
          payload.senha_admin = senha_admin;
        }
        
        const { data, error } = await supabase
          .from('lojas')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
          
        if (error) {
          console.error('[useSaveLoja] Erro no update:', error);
          throw new Error(error.message);
        }
        
        return data;
      } else {
        // Insert
        const { data, error } = await supabase
          .from('lojas')
          .insert({
            nome_loja,
            nome_admin,
            email_admin,
            senha_admin,
            telefone_whatsapp,
            endereco,
            ativa
          })
          .select()
          .single();
          
        if (error) {
          console.error('[useSaveLoja] Erro no insert:', error);
          throw new Error(error.message);
        }
        
        return data;
      }
    },
    onSuccess: () => {
      console.log('[useSaveLoja] Sucesso, invalidando query');
      qc.invalidateQueries({ queryKey: ["lojas"] });
    },
    onError: (error) => {
      console.error('[useSaveLoja] Erro na mutação:', error);
    }
  });
}

export function useDeleteLoja() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      console.log('[useDeleteLoja] Deletando loja:', id);
      const { error } = await supabase.from('lojas').delete().eq('id', id);
      if (error) {
        console.error('[useDeleteLoja] Erro:', error);
        throw new Error(error.message);
      }
    },
    onSuccess: () => {
      console.log('[useDeleteLoja] Sucesso');
      qc.invalidateQueries({ queryKey: ["lojas"] });
    },
  });
}

export function useAtivarDesativarLoja() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ativa }: { id: string; ativa: boolean }) => {
      console.log('[useAtivarDesativarLoja] Toggle:', { id, ativa: !ativa });
      const { error } = await supabase.from('lojas').update({ ativa: !ativa }).eq('id', id);
      if (error) {
        console.error('[useAtivarDesativarLoja] Erro:', error);
        throw new Error(error.message);
      }
    },
    onSuccess: () => {
      console.log('[useAtivarDesativarLoja] Sucesso');
      qc.invalidateQueries({ queryKey: ["lojas"] });
    },
  });
}

export function useChangeLojaPassword() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, novaSenha }: { id: string; novaSenha: string }) => {
      console.log('[useChangeLojaPassword] Alterando senha');
      const { error } = await supabase.from('lojas').update({ senha_admin: novaSenha }).eq('id', id);
      if (error) {
        console.error('[useChangeLojaPassword] Erro:', error);
        throw new Error(error.message);
      }
    },
    onSuccess: () => {
      console.log('[useChangeLojaPassword] Sucesso');
      qc.invalidateQueries({ queryKey: ["lojas"] });
    },
  });
}
