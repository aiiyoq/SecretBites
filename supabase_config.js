// Supabase 配置文件
// 请替换为你的实际 Supabase 项目配置

const SUPABASE_CONFIG = {
    URL: 'https://emwpfqxyposohlubpigi.supabase.co', // 例如: 'https://your-project-id.supabase.co'
    ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtd3BmcXh5cG9zb2hsdWJwaWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1NTA0NTcsImV4cCI6MjA2ODEyNjQ1N30.ordgtJ3yuZHKNiSadYSW54Sm9u31_795fOyi2-HdduY' // 你的匿名公钥
};

// 导出配置
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SUPABASE_CONFIG;
} else {
    window.SUPABASE_CONFIG = SUPABASE_CONFIG;
} 