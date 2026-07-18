import { createClientFromRequest } from 'npm:@base44/sdk@0.8.31';
import bcrypt from 'npm:bcryptjs@2.4.3';

function sanitizeUser(u: any) {
  return {
    id: u.id,
    email: u.email,
    phone: u.phone || '',
    full_name: u.full_name,
    avatar_url: u.avatar_url || null,
    client_type: u.client_type || 'individual',
    business_name: u.business_name || null,
    business_sector: u.business_sector || null,
    rccm: u.rccm || null,
    id_nat: u.id_nat || null,
    kyc_level: u.kyc_level || 'none',
    role: u.role || 'client',
    status: u.is_active === false ? 'inactive' : 'active',
    created_at: u.created_date || null,
    last_login_at: u.last_login_at || null,
  };
}

function newToken() {
  return crypto.randomUUID() + crypto.randomUUID().replace(/-/g, '');
}

Deno.serve(async (req) => {
  try {
    const base44 = createClientFromRequest(req);
    const body = await req.json().catch(() => ({}));
    const action = body.action;

    if (action === 'register') {
      const { email, password, phone, full_name, client_type, business_name, business_sector, rccm, id_nat, avatar_url } = body;
      if (!email || !password || !full_name) {
        return new Response(JSON.stringify({ success: false, error: 'email, password et full_name sont requis' }), { status: 400, headers: { 'Content-Type': 'application/json' } });
      }
      const existing = await base44.asServiceRole.entities.AppUser.filter({ email: email.toLowerCase().trim() });
      if (existing.length > 0) {
        return new Response(JSON.stringify({ success: false, error: 'Un compte existe déjà avec cet email' }), { status: 409, headers: { 'Content-Type': 'application/json' } });
      }
      const password_hash = bcrypt.hashSync(password, 10);
      const token = newToken();
      const expires = new Date(Date.now() + 30 * 24 * 3600 * 1000).toISOString();
      const user = await base44.asServiceRole.entities.AppUser.create({
        email: email.toLowerCase().trim(),
        password_hash,
        phone: phone || '',
        full_name,
        client_type: client_type === 'enterprise' ? 'enterprise' : 'individual',
        business_name: business_name || null,
        business_sector: business_sector || null,
        rccm: rccm || null,
        id_nat: id_nat || null,
        avatar_url: avatar_url || null,
        kyc_level: 'none',
        role: 'client',
        is_active: true,
        session_token: token,
        session_expires: expires,
        last_login_at: new Date().toISOString(),
      });

      // Auto-provision a default IllicoCash account for the new user
      const accountNumber = 'IC-' + Math.floor(100000000 + Math.random() * 900000000);
      await base44.asServiceRole.entities.Account.create({
        user_id: user.id,
        type: 'illicoCash',
        balance: 0,
        currency: 'USD',
        status: 'active',
        account_number: accountNumber,
      });

      return new Response(JSON.stringify({ success: true, access_token: token, refresh_token: token, ...sanitizeUser(user) }), { status: 201, headers: { 'Content-Type': 'application/json' } });
    }

    if (action === 'login') {
      const { email, password } = body;
      if (!email || !password) {
        return new Response(JSON.stringify({ success: false, error: 'email et password sont requis' }), { status: 400, headers: { 'Content-Type': 'application/json' } });
      }
      const matches = await base44.asServiceRole.entities.AppUser.filter({ email: email.toLowerCase().trim() });
      const user = matches[0];
      if (!user || !bcrypt.compareSync(password, user.password_hash)) {
        return new Response(JSON.stringify({ success: false, error: 'Email ou mot de passe incorrect' }), { status: 401, headers: { 'Content-Type': 'application/json' } });
      }
      if (user.is_active === false) {
        return new Response(JSON.stringify({ success: false, error: 'Compte désactivé' }), { status: 403, headers: { 'Content-Type': 'application/json' } });
      }
      const token = newToken();
      const expires = new Date(Date.now() + 30 * 24 * 3600 * 1000).toISOString();
      const updated = await base44.asServiceRole.entities.AppUser.update(user.id, {
        session_token: token,
        session_expires: expires,
        last_login_at: new Date().toISOString(),
      });
      return new Response(JSON.stringify({ success: true, access_token: token, refresh_token: token, ...sanitizeUser({ ...user, ...updated }) }), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }

    if (action === 'refresh') {
      const { refresh_token } = body;
      const matches = await base44.asServiceRole.entities.AppUser.filter({ session_token: refresh_token });
      const user = matches[0];
      if (!user || new Date(user.session_expires) < new Date()) {
        return new Response(JSON.stringify({ success: false, error: 'Session expirée' }), { status: 401, headers: { 'Content-Type': 'application/json' } });
      }
      const token = newToken();
      const expires = new Date(Date.now() + 30 * 24 * 3600 * 1000).toISOString();
      await base44.asServiceRole.entities.AppUser.update(user.id, { session_token: token, session_expires: expires });
      return new Response(JSON.stringify({ success: true, access_token: token, refresh_token: token }), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }

    if (action === 'me') {
      const { access_token } = body;
      const matches = await base44.asServiceRole.entities.AppUser.filter({ session_token: access_token });
      const user = matches[0];
      if (!user || new Date(user.session_expires) < new Date()) {
        return new Response(JSON.stringify({ success: false, error: 'Session invalide' }), { status: 401, headers: { 'Content-Type': 'application/json' } });
      }
      return new Response(JSON.stringify({ success: true, ...sanitizeUser(user) }), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }

    return new Response(JSON.stringify({ success: false, error: 'Action inconnue' }), { status: 400, headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ success: false, error: String(err) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
