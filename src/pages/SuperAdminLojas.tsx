import { useState } from "react";
import { Button } from "@/components/ui/button";
import { useLojas, useSaveLoja, useDeleteLoja, useAtivarDesativarLoja, useChangeLojaPassword } from "@/hooks/use-lojas";
import { Plus, Pencil, Trash2, X, Power, CheckCircle2, XCircle, Key } from "lucide-react";
import { toast } from "sonner";

export default function SuperAdminLojas() {
  const { data: lojas, isLoading } = useLojas();
  const saveLoja = useSaveLoja();
  const deleteLoja = useDeleteLoja();
  const ativarDesativar = useAtivarDesativarLoja();
  const changePassword = useChangeLojaPassword();
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedLoja, setSelectedLoja] = useState<{ id: string; nome_loja: string; email_admin: string } | null>(null);
  const [passwordForm, setPasswordForm] = useState({ novaSenha: "", confirmarSenha: "" });
  const [form, setForm] = useState({
    nome_loja: "", nome_admin: "", email_admin: "", senha_admin: "",
    telefone_whatsapp: "", endereco: "", ativa: true,
  });

  const resetForm = () => {
    setForm({ nome_loja: "", nome_admin: "", email_admin: "", senha_admin: "", telefone_whatsapp: "", endereco: "", ativa: true });
    setEditingId(null);
    setShowForm(false);
  };

  const handleEdit = (loja: any) => {
    setForm({
      nome_loja: loja.nome_loja, nome_admin: loja.nome_admin, email_admin: loja.email_admin,
      senha_admin: "", telefone_whatsapp: loja.telefone_whatsapp || "", endereco: loja.endereco || "", ativa: loja.ativa,
    });
    setEditingId(loja.id);
    setShowForm(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.nome_loja || !form.nome_admin || !form.email_admin) {
      toast.error("Preencha os campos obrigatórios.");
      return;
    }
    try {
      await saveLoja.mutateAsync({
        id: editingId || undefined, 
        nome_loja: form.nome_loja, 
        nome_admin: form.nome_admin,
        email_admin: form.email_admin, 
        senha_admin: form.senha_admin || undefined,
        telefone_whatsapp: form.telefone_whatsapp || undefined, 
        endereco: form.endereco || undefined, 
        ativa: form.ativa,
      });
      toast.success(editingId ? "Loja atualizada!" : "Loja criada!");
      resetForm();
    } catch (error: any) {
      console.error('Erro ao salvar loja:', error);
      const msg = error?.message || 'Erro desconhecido';
      if (msg.includes('duplicate') || msg.includes('already exists')) {
        toast.error('Este email já está cadastrado!');
      } else if (msg.includes('Lock')) {
        toast.error('Erro de conexão. Tente novamente.');
      } else {
        toast.error(`Erro: ${msg}`);
      }
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Tem certeza que deseja excluir esta loja?")) return;
    try { await deleteLoja.mutateAsync(id); toast.success("Loja excluída!"); } catch { toast.error("Erro ao excluir."); }
  };

  const handleToggleAtiva = async (id: string, ativa: boolean) => {
    try { await ativarDesativar.mutateAsync({ id, ativa: !ativa }); toast.success(ativa ? "Loja desativada!" : "Loja ativada!"); } catch { toast.error("Erro ao alterar status."); }
  };

  const handleOpenPasswordModal = (loja: any) => {
    setSelectedLoja({ id: loja.id, nome_loja: loja.nome_loja, email_admin: loja.email_admin });
    setPasswordForm({ novaSenha: "", confirmarSenha: "" });
    setShowPasswordModal(true);
  };

  const handleClosePasswordModal = () => { setShowPasswordModal(false); setSelectedLoja(null); setPasswordForm({ novaSenha: "", confirmarSenha: "" }); };

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!passwordForm.novaSenha || !passwordForm.confirmarSenha) { toast.error("Preencha todos os campos."); return; }
    if (passwordForm.novaSenha !== passwordForm.confirmarSenha) { toast.error("As senhas não coincidem."); return; }
    if (passwordForm.novaSenha.length < 6) { toast.error("A senha deve ter pelo menos 6 caracteres."); return; }
    try {
      await changePassword.mutateAsync({ id: selectedLoja!.id, novaSenha: passwordForm.novaSenha });
      toast.success("Senha alterada com sucesso!");
      handleClosePasswordModal();
    } catch (error: any) {
      toast.error(`Erro: ${error?.message || 'Erro desconhecido'}`);
    }
  };

  if (isLoading) return <div className="min-h-screen flex items-center justify-center"><p className="font-heading text-sm uppercase text-muted-foreground">CARREGANDO...</p></div>;

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="font-heading text-2xl uppercase">Gerenciar Lojas</h1><p className="text-muted-foreground text-sm">Painel do Super Administrador</p></div>
        <Button onClick={() => { resetForm(); setShowForm(true); }}><Plus className="h-4 w-4 mr-2" /> NOVA LOJA</Button>
      </div>

      {showForm && (
        <div className="bg-card border-2 border-border p-6 mb-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="font-heading text-sm uppercase">{editingId ? "EDITAR LOJA" : "NOVA LOJA"}</h3>
            <button onClick={resetForm}><X className="h-4 w-4" /></button>
          </div>
          <form onSubmit={handleSave} className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">NOME DA LOJA *</label>
              <input value={form.nome_loja} onChange={(e) => setForm({ ...form, nome_loja: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" required /></div>
            <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">NOME DO ADMIN *</label>
              <input value={form.nome_admin} onChange={(e) => setForm({ ...form, nome_admin: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" required /></div>
            <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">EMAIL DO ADMIN *</label>
              <input type="email" value={form.email_admin} onChange={(e) => setForm({ ...form, email_admin: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" required /></div>
            <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">SENHA {!editingId && "*"}</label>
              <input type="password" value={form.senha_admin} onChange={(e) => setForm({ ...form, senha_admin: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" required={!editingId} placeholder={editingId ? "Deixe em branco para manter" : ""} /></div>
            <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">TELEFONE/WHATSAPP</label>
              <input value={form.telefone_whatsapp} onChange={(e) => setForm({ ...form, telefone_whatsapp: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" /></div>
            <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">ENDEREÇO</label>
              <input value={form.endereco} onChange={(e) => setForm({ ...form, endereco: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" /></div>
            <div className="border-2 border-border p-3 flex items-center gap-2">
              <input type="checkbox" id="ativa" checked={form.ativa} onChange={(e) => setForm({ ...form, ativa: e.target.checked })} className="w-4 h-4" />
              <label htmlFor="ativa" className="font-heading text-xs uppercase">Loja Ativa</label>
            </div>
            <div className="md:col-span-2"><Button type="submit" size="lg" className="w-full" disabled={saveLoja.isPending}>{editingId ? "SALVAR ALTERAÇÕES" : "CRIAR LOJA"}</Button></div>
          </form>
        </div>
      )}

      {showPasswordModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-card border-2 border-border p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-heading text-sm uppercase flex items-center gap-2"><Key className="h-4 w-4" /> ALTERAR SENHA</h3>
              <button onClick={handleClosePasswordModal}><X className="h-4 w-4" /></button>
            </div>
            <div className="mb-4">
              <p className="text-sm text-muted-foreground"><span className="font-semibold">Loja:</span> {selectedLoja?.nome_loja}</p>
              <p className="text-sm text-muted-foreground"><span className="font-semibold">Email:</span> {selectedLoja?.email_admin}</p>
            </div>
            <form onSubmit={handlePasswordSubmit} className="space-y-4">
              <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">NOVA SENHA *</label>
                <input type="password" value={passwordForm.novaSenha} onChange={(e) => setPasswordForm({ ...passwordForm, novaSenha: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" required placeholder="Mínimo 6 caracteres" /></div>
              <div className="border-2 border-border p-3"><label className="font-heading text-xs uppercase block mb-1">CONFIRMAR SENHA *</label>
                <input type="password" value={passwordForm.confirmarSenha} onChange={(e) => setPasswordForm({ ...passwordForm, confirmarSenha: e.target.value })} className="w-full bg-transparent font-body text-sm outline-none" required placeholder="Repita a nova senha" /></div>
              <div className="flex gap-2">
                <Button type="button" variant="outline" onClick={handleClosePasswordModal} className="flex-1">CANCELAR</Button>
                <Button type="submit" className="flex-1" disabled={changePassword.isPending}>ALTERAR SENHA</Button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="border-2 border-border overflow-x-auto">
        <table className="w-full">
          <thead className="bg-muted">
            <tr>
              <th className="text-left p-3 font-heading text-xs uppercase">STATUS</th>
              <th className="text-left p-3 font-heading text-xs uppercase">LOJA</th>
              <th className="text-left p-3 font-heading text-xs uppercase hidden md:table-cell">ADMIN</th>
              <th className="text-left p-3 font-heading text-xs uppercase hidden lg:table-cell">CONTATO</th>
              <th className="text-left p-3 font-heading text-xs uppercase hidden lg:table-cell">CRIADA EM</th>
              <th className="text-right p-3 font-heading text-xs uppercase">AÇÕES</th>
            </tr>
          </thead>
          <tbody>
            {(lojas || []).map((loja) => (
              <tr key={loja.id} className="border-t-2 border-border">
                <td className="p-3">{loja.ativa ? (<span className="flex items-center gap-1 text-green-600"><CheckCircle2 className="h-4 w-4" /><span className="font-heading text-xs uppercase">Ativa</span></span>) : (<span className="flex items-center gap-1 text-red-600"><XCircle className="h-4 w-4" /><span className="font-heading text-xs uppercase">Inativa</span></span>)}</td>
                <td className="p-3"><div><p className="font-body text-sm font-semibold">{loja.nome_loja}</p><p className="text-xs text-muted-foreground">{loja.id.substring(0, 8)}...</p></div></td>
                <td className="p-3 hidden md:table-cell"><div><p className="font-body text-sm">{loja.nome_admin}</p><p className="text-xs text-muted-foreground">{loja.email_admin}</p></div></td>
                <td className="p-3 hidden lg:table-cell"><div>{loja.telefone_whatsapp && (<p className="text-sm">{loja.telefone_whatsapp}</p>)}{loja.endereco && (<p className="text-xs text-muted-foreground truncate max-w-xs">{loja.endereco}</p>)}</div></td>
                <td className="p-3 hidden lg:table-cell"><p className="text-sm text-muted-foreground">{new Date(loja.created_at).toLocaleDateString('pt-BR')}</p></td>
                <td className="p-3 text-right">
                  <div className="flex justify-end gap-2">
                    <button onClick={() => handleOpenPasswordModal(loja)} className="p-1 hover:text-accent" title="Alterar Senha"><Key className="h-4 w-4" /></button>
                    <button onClick={() => handleToggleAtiva(loja.id, loja.ativa)} className="p-1 hover:text-accent" title={loja.ativa ? "Desativar" : "Ativar"}><Power className="h-4 w-4" /></button>
                    <button onClick={() => handleEdit(loja)} className="p-1 hover:text-accent" title="Editar"><Pencil className="h-4 w-4" /></button>
                    <button onClick={() => handleDelete(loja.id)} className="p-1 hover:text-destructive" title="Excluir"><Trash2 className="h-4 w-4" /></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
