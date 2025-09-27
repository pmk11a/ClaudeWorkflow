{{--
    Dashboard Welcome Info Component

    Displays user welcome information in a clean card format
    Props: $user (required)
--}}

@props(['user'])

<x-card title="Welcome Information" icon="fas fa-info-circle">
    <div class="welcome-info">
        <h4>🎉 Login Successful!</h4>
        <p class="text-muted mb-3">Welcome to DAPEN Smart Accounting System</p>

        <div class="row">
            <div class="col-md-6">
                <ul class="list-unstyled">
                    <li><strong>Username:</strong> {{ $user->USERID }}</li>
                    <li><strong>Full Name:</strong> {{ $user->FullName }}</li>
                    <li><strong>Level:</strong> {{ $user->TINGKAT }} ({{ $user->getUserLevelName() }})</li>
                </ul>
            </div>
            <div class="col-md-6">
                <ul class="list-unstyled">
                    <li><strong>Department:</strong> {{ $user->kodeBag ?? 'N/A' }}</li>
                    <li><strong>Position:</strong> {{ $user->KodeJab ?? 'N/A' }}</li>
                    <li><strong>Last Login:</strong> Current session</li>
                </ul>
            </div>
        </div>
    </div>
</x-card>