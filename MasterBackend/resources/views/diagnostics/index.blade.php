<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Diagnostics</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .status-connected { color: green; }
        .status-failed { color: red; }
        .section { margin-bottom: 30px; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .section h2 { margin-top: 0; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        .test-form { margin-top: 20px; }
        .test-form input, .test-form button { margin: 5px 0; padding: 8px; }
        .test-form button { background-color: #007cba; color: white; border: none; cursor: pointer; }
        .test-result { margin-top: 10px; padding: 10px; border-radius: 5px; }
        .result-success { background-color: #d4edda; color: #155724; }
        .result-error { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <h1>Database Connection & Authentication Diagnostics</h1>
    <p><strong>Generated:</strong> {{ $diagnostics['timestamp'] }}</p>
    <p><strong>Environment:</strong> {{ $diagnostics['environment'] }}</p>

    <!-- Database Connection Status -->
    <div class="section">
        <h2>Database Connection</h2>
        @if($diagnostics['database']['status'] === 'connected')
            <p class="status-connected">✓ Connected Successfully</p>
            <table>
                <tr><th>Driver</th><td>{{ $diagnostics['database']['driver'] }}</td></tr>
                <tr><th>Server Info</th><td>{{ $diagnostics['database']['server_info'] }}</td></tr>
                <tr><th>Server Version</th><td>{{ $diagnostics['database']['server_version'] }}</td></tr>
                <tr><th>Connection Status</th><td>{{ $diagnostics['database']['connection_status'] }}</td></tr>
            </table>
        @else
            <p class="status-failed">✗ Connection Failed</p>
            <p><strong>Error:</strong> {{ $diagnostics['database']['error'] }}</p>
            <p><strong>Error Code:</strong> {{ $diagnostics['database']['error_code'] }}</p>
        @endif
    </div>

    <!-- User Statistics -->
    <div class="section">
        <h2>User Statistics</h2>
        @if($diagnostics['users']['status'] === 'success')
            <table>
                <tr><th>Total Users</th><td>{{ $diagnostics['users']['total_users'] }}</td></tr>
                <tr><th>Active Users</th><td>{{ $diagnostics['users']['active_users'] }}</td></tr>
                <tr><th>Users with Passwords</th><td>{{ $diagnostics['users']['users_with_passwords'] }}</td></tr>
            </table>

            <h3>Sample Users</h3>
            <table>
                <tr><th>User ID</th><th>Name</th><th>Status</th><th>Level</th><th>Has Password</th></tr>
                @foreach($diagnostics['users']['sample_users'] as $user)
                <tr>
                    <td>{{ $user['userid'] }}</td>
                    <td>{{ $user['name'] }}</td>
                    <td>{{ $user['status'] ? 'Active' : 'Inactive' }}</td>
                    <td>{{ $user['level'] }}</td>
                    <td>{{ $user['has_password'] ? 'Yes' : 'No' }}</td>
                </tr>
                @endforeach
            </table>
        @else
            <p class="status-failed">✗ Failed to retrieve user data</p>
            <p><strong>Error:</strong> {{ $diagnostics['users']['error'] }}</p>
        @endif
    </div>

    <!-- Configuration -->
    <div class="section">
        <h2>Database Configuration</h2>
        <table>
            <tr><th>Host</th><td>{{ $diagnostics['configuration']['host'] }}</td></tr>
            <tr><th>Port</th><td>{{ $diagnostics['configuration']['port'] }}</td></tr>
            <tr><th>Database</th><td>{{ $diagnostics['configuration']['database'] }}</td></tr>
            <tr><th>Username</th><td>{{ $diagnostics['configuration']['username'] }}</td></tr>
            <tr><th>Encrypt</th><td>{{ $diagnostics['configuration']['encrypt'] ? 'true' : 'false' }}</td></tr>
            <tr><th>Trust Server Certificate</th><td>{{ $diagnostics['configuration']['trust_server_certificate'] ? 'true' : 'false' }}</td></tr>
            <tr><th>Timeout</th><td>{{ $diagnostics['configuration']['timeout'] ?? 'default' }}</td></tr>
            <tr><th>PHP Version</th><td>{{ $diagnostics['configuration']['php_version'] }}</td></tr>
            <tr><th>Laravel Version</th><td>{{ $diagnostics['configuration']['laravel_version'] }}</td></tr>
        </table>
    </div>

    <!-- User Authentication Test -->
    <div class="section">
        <h2>Test User Authentication</h2>
        <form class="test-form" id="userTestForm">
            @csrf
            <div>
                <label>Username:</label><br>
                <input type="text" name="username" id="username" required>
            </div>
            <div>
                <label>Password (optional):</label><br>
                <input type="password" name="password" id="password">
            </div>
            <div>
                <button type="submit">Test User</button>
            </div>
        </form>
        <div id="testResult"></div>
    </div>

    <script>
        document.getElementById('userTestForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const resultDiv = document.getElementById('testResult');
            
            resultDiv.innerHTML = 'Testing...';
            
            fetch('/diagnostics/test-user', {
                method: 'POST',
                body: formData,
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('input[name="_token"]').value
                }
            })
            .then(response => response.json())
            .then(data => {
                let html = '<div class="test-result ' + (data.status === 'found' ? 'result-success' : 'result-error') + '">';
                
                if (data.status === 'found') {
                    html += '<h4>User Found</h4>';
                    html += '<p><strong>User ID:</strong> ' + data.user.userid + '</p>';
                    html += '<p><strong>Name:</strong> ' + (data.user.name || 'N/A') + '</p>';
                    html += '<p><strong>Status:</strong> ' + (data.user.active ? 'Active' : 'Inactive') + '</p>';
                    html += '<p><strong>Level:</strong> ' + (data.user.level || 'N/A') + '</p>';
                    html += '<p><strong>Department:</strong> ' + (data.user.department || 'N/A') + '</p>';
                    html += '<p><strong>Has Password:</strong> ' + (data.user.has_password ? 'Yes' : 'No') + '</p>';
                    html += '<p><strong>Password Type:</strong> ' + data.user.password_type + '</p>';
                    
                    if (data.password_test) {
                        html += '<h5>Password Test Result</h5>';
                        html += '<p><strong>Valid:</strong> ' + (data.password_test.overall_valid ? 'Yes' : 'No') + '</p>';
                        html += '<p><strong>Method:</strong> ' + data.password_test.method + '</p>';
                    }
                } else if (data.status === 'not_found') {
                    html += '<h4>User Not Found</h4>';
                    html += '<p>' + data.message + '</p>';
                } else {
                    html += '<h4>Error</h4>';
                    html += '<p>' + data.error + '</p>';
                }
                
                html += '</div>';
                resultDiv.innerHTML = html;
            })
            .catch(error => {
                resultDiv.innerHTML = '<div class="test-result result-error"><h4>Request Failed</h4><p>' + error.message + '</p></div>';
            });
        });
    </script>
</body>
</html>