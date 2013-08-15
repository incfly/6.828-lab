// User-level IPC library routines

#include <inc/lib.h>

// Receive a value via IPC and return it.
// If 'pg' is nonnull, then any page sent by the sender will be mapped at
//	that address.
// If 'from_env_store' is nonnull, then store the IPC sender's envid in
//	*from_env_store.
// If 'perm_store' is nonnull, then store the IPC sender's page permission
//	in *perm_store (this is nonzero iff a page was successfully
//	transferred to 'pg').
// If the system call fails, then store 0 in *fromenv and *perm (if
//	they're nonnull) and return the error.
// Otherwise, return the value sent by the sender
//
// Hint:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
//   意思就是应该对sys_ipc_recv()中的dstva参数，用一个>= UTOP的值

#define NO_PAGE_MAP (UTOP+1)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	void *dstva = pg ? pg : (void *)NO_PAGE_MAP;
	int r;
	r = sys_ipc_recv(dstva);
	if (from_env_store)
		*from_env_store = r == 0? thisenv->env_ipc_from : 0;
	if (perm_store)
		*perm_store = r == 0 ? thisenv->env_ipc_perm : 0;
	if (r != 0)
		panic("sys_ipc_recv() failed in ipc_recv\n");
	return r == 0 ? thisenv->env_ipc_value : r;
}

// Send 'val' (and 'pg' with 'perm', if 'pg' is nonnull) to 'toenv'.
// This function keeps trying until it succeeds.
// It should panic() on any error other than -E_IPC_NOT_RECV.
//
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	void *va = pg ? pg : (void *)NO_PAGE_MAP;
	while(1){
		r = sys_ipc_try_send(to_env, val, va, perm);
		if (r == 0)
			break;
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send() -> sys_ipc_try_send(): %e\n", r);
	}
	sys_yield();
}

// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
