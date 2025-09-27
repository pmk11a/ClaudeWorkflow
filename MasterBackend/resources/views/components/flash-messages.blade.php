{{--
    Flash Messages Component

    Clean, reusable component for displaying server-side flash messages
    Usage: <x-flash-messages />
--}}

@if(session()->has('error') || session()->has('success') || $errors->any())
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const flashMessages = {
            @if(session('error'))
                error: @json(session('error')),
            @endif
            @if(session('success'))
                success: @json(session('success')),
            @endif
            @if($errors->any())
                errors: @json($errors->all()),
            @endif
        };

        // Use the DapenAuth flash message handler
        if (window.DapenAuth && typeof window.DapenAuth.processFlashMessages === 'function') {
            window.DapenAuth.processFlashMessages(flashMessages);
        }
    });
</script>
@endif