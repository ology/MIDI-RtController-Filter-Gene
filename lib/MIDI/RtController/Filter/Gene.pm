package MIDI::RtController::Filter::Gene;

# ABSTRACT: Gene's RtController filters

use v5.36;

our $VERSION = '0.0100';

use Moo;
use strictures 2;
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::RtController ();
  use MIDI::RtController::Filter::Gene ();

  my $rtc = MIDI::RtController->new;

  my $filter = MIDI::RtController::Filter::Gene->new(rtc => $rtc);

  $rtc->add_filter('foo', note_on => $filter->can('foo'));

  $rtc->run;

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Gene> is the collection of Gene's
L<MIDI::RtController> filters.

=cut

=head1 ATTRIBUTES

=head2 rtc

  $rtc = $filter->rtc;

The L<MIDI::RtController> instance.

=cut

has rtc => (
    is  => 'ro',
    isa => sub { die 'Invalid rtc' unless ref($_[0]) eq 'MIDI::RtController' },
);

=head1 METHODS

All filter methods must accept a delta-time and a MIDI event ARRAY
reference, like:

  sub pedal_tone ($dt, $event) {
    my ($event_type, $chan, $note, $value) = $event->@*;
    ...
    return $boolean;
  }

A filter also must return a boolean value. This tells
L<MIDI::RtController> to continue processing other known filters or
not.

=head2 pedal_tone

  PEDAL, $note, $note + 7

Where C<PEDAL> is a constant (C<55>) for G below middle-C.

=cut

sub _pedal_notes ($self, $note) {
    return $self->pedal, $note, $note + 7;
}
sub pedal_tone ($self, $dt, $event) {
    my ($ev, $chan, $note, $vel) = $event->@*;
    my @notes = $self->_pedal_notes($note);
    my $delay_time = 0;
    for my $n (@notes) {
        $delay_time += $self->delay;
        $self->rtc->delay_send($delay_time, [ $ev, $self->channel, $n, $vel ]);
    }
    return 0;
}

1;
__END__

=head1 SEE ALSO

L<Another::Module>

L<http://somewhere>

=cut
