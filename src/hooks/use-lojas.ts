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
      
      // Tenta usar a função RPC primeiro (mais segura e atômica)
      try {
        const { error: rpcError } = await supabase.rpc('excluir_loja_com_cascade', { loja_id: id });
        
        if (rpcError) {
          // Se a função não existir ou falhar, fallback para o método manual
          console.log('[useDeleteLoja] RPC não existe ou falhou, usando método manual:', rpcError);
        } else {
          console.log('[useDeleteLoja] Loja excluída via RPC');
          return;
        }
      } catch (rpcException: any) {
        console.log('[useDeleteLoja] Erro na RPC:', rpcException?.message);
      }
      
      // Fallback: método manual de exclusão
      console.log('[useDeleteLoja] Usando fallback manual...');
      
      // Verificar quais tabelas têm dados para esta loja
      const tablesToClean = ['categorias', 'produtos', 'pedidos', 'configuracoes'];
      
      for (const table of tablesToClean) {
        try {
          // Primeiro verifica se há registros
          const { data: countData, error: countError } = await supabase
            .from(table)
            .select('id', { count: 'exact', head: true })
            .eq('loja_id', id);
          
          if (countError) {
            console.log(`[useDeleteLoja] Tabela ${table} não tem coluna loja_id`);
            continue;
          }
          
          const count = countData?.length || 0;
          console.log(`[useDeleteLoja] Tabela ${table} tem ${count} registros para esta loja`);
          
          // Se tiver registros, exclui
          if (count > 0) {
            const { error: deleteError, data: deletedData } = await supabase
              .from(table)
              .delete()
              .eq('loja_id', id)
              .select();
            
            if (deleteError) {
              console.error(`[useDeleteLoja] ERRO ao limpar tabela ${table}:`, deleteError);
            } else {
              console.log(`[useDeleteLoja] Tabela ${table} limpa com sucesso (${deletedData?.length} registros)`);
            }
          }
        } catch (e: any) {
          console.log(`[useDeleteLoja] Exceção ao processar tabela ${table}:`, e?.message || e);
        }
      }
      
      // Agora exclui a loja
      console.log('[useDeleteLoja] Tentando excluir loja...');
      const { error: deleteLojaError, data: deletedLoja } = await supabase.from('lojas').delete().eq('id', id).select();
      if (deleteLojaError) {
        console.error('[useDeleteLoja] ERRO FATAL ao excluir loja:', deleteLojaError);
        console.error('[useDeleteLoja] Detalhes do erro:', JSON.stringify(deleteLojaError, null, 2));
        throw new Error(deleteLojaError.message || 'Erro ao excluir loja');
      }
      console.log('[useDeleteLoja] Loja excluída com sucesso');
    },
    onSuccess: () => {
      console.log('[useDeleteLoja] Sucesso');
      qc.invalidateQueries({ queryKey: ["lojas"] });
    },
    onError: (error) => {
      console.error('[useDeleteLoja] Erro na mutação:', error);
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
