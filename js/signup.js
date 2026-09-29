(function(){
  function openSignup(){
    var modal=document.getElementById("modal");
    var body=document.getElementById("modalBody");
    if(!modal||!body)return;
    modal.classList.remove("hidden");
    modal.classList.add("flex");
    modal.style.display="flex";
    body.innerHTML='<h2 class="text-2xl font-black">Join ConnectWorld</h2><p class="text-slate-500 mt-2">Create your account and meet people globally.</p><form id="standaloneSignupForm" class="mt-5 grid gap-3"><input id="suName" required class="border rounded-xl p-3" placeholder="Full name"><input id="suUsername" required class="border rounded-xl p-3" placeholder="Username"><input id="suCountry" required class="border rounded-xl p-3" placeholder="Country"><input id="suEmail" required class="border rounded-xl p-3" placeholder="Email address" type="email"><input id="suPassword" required minlength="6" class="border rounded-xl p-3" placeholder="Password" type="password"><button type="submit" class="bg-blue-600 text-white py-3 rounded-xl font-bold">Create account</button></form><button type="button" id="suLogin" class="w-full mt-3 text-sm text-blue-600">Already have an account? Log in</button>';
    var form=document.getElementById("standaloneSignupForm");
    form.addEventListener("submit",async function(e){
      e.preventDefault();
      var btn=form.querySelector("button[type=submit]");
      btn.disabled=true; btn.textContent="Creating account...";
      try{
        if(!window.ConnectWorld)throw new Error("ConnectWorld is still loading. Please try again.");
        var data=await window.ConnectWorld.signUp(
          document.getElementById("suEmail").value.trim(),
          document.getElementById("suPassword").value,
          {
            full_name:document.getElementById("suName").value.trim(),
            username:document.getElementById("suUsername").value.trim(),
            country:document.getElementById("suCountry").value.trim()
          }
        );
        if(window.toast)toast(data.session?"Account created!":"Account created. Check your email to confirm it.");
        if(window.closeModal)closeModal();
      }catch(err){
        if(window.toast)toast(err.message||"Could not create account");
        else alert(err.message||"Could not create account");
        btn.disabled=false; btn.textContent="Create account";
      }
    });
    document.getElementById("suLogin").onclick=function(){
      if(window.openModal)openModal("login");
    };
  }
  function bind(){
    ["headerSignUpBtn","createProfileBtn"].forEach(function(id){
      var el=document.getElementById(id);
      if(el)el.onclick=function(e){e.preventDefault();openSignup();return false;};
    });
  }
  if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",bind);else bind();
})();